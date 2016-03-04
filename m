From: Parav Pandit <pandit.parav@gmail.com>
Subject: Re: [PATCH 3/4] infiniband: hns: add Hisilicon RoCE support(driver code)
Date: Fri, 4 Mar 2016 15:07:19 +0530
Message-ID: <CAG53R5WfQR1jJUOi1fjY=oEgsK_EAxkA9SiDPV_KHLHsmqg0BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
	"Hefty, Sean" <sean.hefty@intel.com>, hal.rosenstock@gmail.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jiri@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, oulijun@huawei.com,
	haifeng.wei@huawei.com, yisen.zhuang@huawei.com,
	yankejian@huawei.com, lisheng011@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 4, 2016 at 2:11 PM, Wei Hu(Xavier) <xavier.huwei@huawei.com> wrote:
> +
> +int hns_roce_register_device(struct hns_roce_dev *hr_dev)
> +{
> +       int ret;
> +       struct hns_roce_ib_iboe *iboe = NULL;
> +       struct ib_device *ib_dev = NULL;
> +       struct device *dev = &hr_dev->pdev->dev;
> +
> +       iboe = &hr_dev->iboe;
> +
> +       ib_dev = &hr_dev->ib_dev;
> +       strlcpy(ib_dev->name, "hisi_%d", IB_DEVICE_NAME_MAX);
> +
> +       ib_dev->owner                   = THIS_MODULE;
> +       ib_dev->node_type               = RDMA_NODE_IB_CA;
> +       ib_dev->dma_device              = dev;
> +
> +       ib_dev->phys_port_cnt           = hr_dev->caps.num_ports;
> +       ib_dev->local_dma_lkey          = hr_dev->caps.reserved_lkey;
> +       ib_dev->num_comp_vectors        = hr_dev->caps.num_comp_vectors;
> +       ib_dev->uverbs_abi_ver          = 1;
> +       ib_dev->uverbs_cmd_mask         =
> +               (1ULL << IB_USER_VERBS_CMD_GET_CONTEXT) |
> +               (1ULL << IB_USER_VERBS_CMD_QUERY_DEVICE) |
> +               (1ULL << IB_USER_VERBS_CMD_QUERY_PORT) |
> +               (1ULL << IB_USER_VERBS_CMD_ALLOC_PD) |
> +               (1ULL << IB_USER_VERBS_CMD_DEALLOC_PD) |
> +               (1ULL << IB_USER_VERBS_CMD_REG_MR) |
> +               (1ULL << IB_USER_VERBS_CMD_DEREG_MR) |
> +               (1ULL << IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
> +               (1ULL << IB_USER_VERBS_CMD_CREATE_CQ) |
> +               (1ULL << IB_USER_VERBS_CMD_DESTROY_CQ) |
> +               (1ULL << IB_USER_VERBS_CMD_CREATE_QP) |
> +               (1ULL << IB_USER_VERBS_CMD_MODIFY_QP) |
> +               (1ULL << IB_USER_VERBS_CMD_QUERY_QP) |
> +               (1ULL << IB_USER_VERBS_CMD_DESTROY_QP);
> +

Since SRQ is not supported in this driver version, can you keep
remaining code base also to not bother about SRQ specifically
poll_cq_one, modify_qp, destroy_qp etc?
SRQ support can come as complete additional patch along with cmd_mask,
callbacks and rest of the code.
