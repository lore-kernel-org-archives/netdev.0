From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 6/6] qedi: Add support for data path.
Date: Tue, 8 Nov 2016 19:09:54 +0800
Message-ID: <201611081941.8e9Ut5J9%fengguang.wu@intel.com>
References: <1478588223-16183-7-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, martin.petersen@oracle.com, lduncan@suse.com,
        cleech@redhat.com, linux-scsi@vger.kernel.org,
        netdev@vger.kernel.org, QLogic-Storage-Upstream@cavium.com,
        Yuval.Mintz@cavium.com
To: Manish Rangankar <manish.rangankar@cavium.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478588223-16183-7-git-send-email-manish.rangankar@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Manish,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.9-rc4 next-20161028]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Manish-Rangankar/qed-Add-support-for-hardware-offloaded-iSCSI/20161108-180027
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/scsi/qedi/qedi_fw.c:2179:31: sparse: incompatible types in comparison expression (different base types)

vim +2179 drivers/scsi/qedi/qedi_fw.c

  2163		fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
  2164	
  2165		memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
  2166		cmd->task_id = tid;
  2167	
  2168		/* Ystorm context */
  2169		fw_cmd = &fw_task_ctx->ystorm_st_context.pdu_hdr.cmd;
  2170		SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_ATTR, ISCSI_ATTR_SIMPLE);
  2171	
  2172		if (sc->sc_data_direction == DMA_TO_DEVICE) {
  2173			if (conn->session->initial_r2t_en) {
  2174				fw_task_ctx->ustorm_ag_context.exp_data_acked =
  2175					min((conn->session->imm_data_en *
  2176					    conn->max_xmit_dlength),
  2177					    conn->session->first_burst);
  2178				fw_task_ctx->ustorm_ag_context.exp_data_acked =
> 2179				      min(fw_task_ctx->ustorm_ag_context.exp_data_acked,
  2180					  scsi_bufflen(sc));
  2181			} else {
  2182				fw_task_ctx->ustorm_ag_context.exp_data_acked =
  2183				      min(conn->session->first_burst, scsi_bufflen(sc));
  2184			}
  2185	
  2186			SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_WRITE, 1);
  2187			task_type = ISCSI_TASK_TYPE_INITIATOR_WRITE;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
