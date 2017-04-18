From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Tue, 18 Apr 2017 10:22:47 +1000
Message-ID: <20170418002247.GB11300@gwshan>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492137045.28586.26.camel@perches.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:40744 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754196AbdDRAXt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 20:23:49 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I0NchZ023429
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 20:23:49 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29vwf49e08-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 20:23:48 -0400
Received: from localhost
        by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 18 Apr 2017 10:23:46 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I0NahN54591530
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:23:44 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I0NBXE025320
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:23:12 +1000
Content-Disposition: inline
In-Reply-To: <1492137045.28586.26.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 07:30:45PM -0700, Joe Perches wrote:
>On Thu, 2017-04-13 at 17:48 +1000, Gavin Shan wrote:
>> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
>> packets sent and received over all packages and channels. It's useful
>> to diagnose NCSI problems, especially when NCSI packages and channels
>> aren't probed properly. The statistics can be gained from debugfs file
>> as below:
>> 
>>  # cat /sys/kernel/debug/ncsi/eth0/stats
>> 
>>  CMD          OK       TIMEOUT  ERROR
>>  =======================================
>>  CIS          32       29       0
>>  SP           10       7        0
>>  DP           17       14       0
>>  EC           1        0        0
>>  ECNT         1        0        0
>>  AE           1        0        0
>>  GLS          11       0        0
>>  SMA          1        0        0
>>  EBF          1        0        0
>>  GVI          2        0        0
>>  GC           2        0        0
>
>more trivia:
>
>> diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
>[]
>> @@ -23,6 +23,235 @@
>>  #include "ncsi-pkt.h"
>>  
>>  static struct dentry *ncsi_dentry;
>> +static struct ncsi_pkt_handler {
>> +	unsigned char	type;
>> +	const char	*name;
>> +} ncsi_pkt_handlers[] = {
>> +	{ NCSI_PKT_CMD_CIS,    "CIS"    },
>> +	{ NCSI_PKT_CMD_SP,     "SP"     },
>> +	{ NCSI_PKT_CMD_DP,     "DP"     },
>> +	{ NCSI_PKT_CMD_EC,     "EC"     },
>> +	{ NCSI_PKT_CMD_DC,     "DC"     },
>> +	{ NCSI_PKT_CMD_RC,     "RC"     },
>> +	{ NCSI_PKT_CMD_ECNT,   "ECNT"   },
>> +	{ NCSI_PKT_CMD_DCNT,   "DCNT"   },
>> +	{ NCSI_PKT_CMD_AE,     "AE"     },
>> +	{ NCSI_PKT_CMD_SL,     "SL"     },
>> +	{ NCSI_PKT_CMD_GLS,    "GLS"    },
>> +	{ NCSI_PKT_CMD_SVF,    "SVF"    },
>> +	{ NCSI_PKT_CMD_EV,     "EV"     },
>> +	{ NCSI_PKT_CMD_DV,     "DV"     },
>> +	{ NCSI_PKT_CMD_SMA,    "SMA"    },
>> +	{ NCSI_PKT_CMD_EBF,    "EBF"    },
>> +	{ NCSI_PKT_CMD_DBF,    "DBF"    },
>> +	{ NCSI_PKT_CMD_EGMF,   "EGMF"   },
>> +	{ NCSI_PKT_CMD_DGMF,   "DGMF"   },
>> +	{ NCSI_PKT_CMD_SNFC,   "SNFC"   },
>> +	{ NCSI_PKT_CMD_GVI,    "GVI"    },
>> +	{ NCSI_PKT_CMD_GC,     "GC"     },
>> +	{ NCSI_PKT_CMD_GP,     "GP"     },
>> +	{ NCSI_PKT_CMD_GCPS,   "GCPS"   },
>> +	{ NCSI_PKT_CMD_GNS,    "GNS"    },
>> +	{ NCSI_PKT_CMD_GNPTS,  "GNPTS"  },
>> +	{ NCSI_PKT_CMD_GPS,    "GPS"    },
>> +	{ NCSI_PKT_CMD_OEM,    "OEM"    },
>> +	{ NCSI_PKT_CMD_PLDM,   "PLDM"   },
>> +	{ NCSI_PKT_CMD_GPUUID, "GPUUID" },
>
>I don't know how common these are and how
>intelligible these acronyms are to knowledgeable
>developer/users, but maybe it'd be better to
>spell out what these are instead of having to
>look up what the acronyms stand for
>
>	CIS - Clear Initial State
>	SP - Select Package
>	etc...
>
>Maybe copy the descriptions from the ncsi-pkt.h file
>

Joe, good question. As these decriptive strings are part of
the output from ncsi/eth0/stats and input to ncsi/eth0/pkt,
I intended to keep them short enough. Also, this debugging
interface would service developers who knows NCSI protocol
and perhaps know the meanings of these acronyms.

Thanks,
Gavin

>#define NCSI_PKT_CMD_CIS	0x00 /* Clear Initial State              */
>#define NCSI_PKT_CMD_SP		0x01 /* Select Package                   */
>#define NCSI_PKT_CMD_DP		0x02 /* Deselect Package                 */
>#define NCSI_PKT_CMD_EC		0x03 /* Enable Channel                   */
>#define NCSI_PKT_CMD_DC		0x04 /* Disable Channel                  */
>#define NCSI_PKT_CMD_RC		0x05 /* Reset Channel                    */
>#define NCSI_PKT_CMD_ECNT	0x06 /* Enable Channel Network Tx        */
>#define NCSI_PKT_CMD_DCNT	0x07 /* Disable Channel Network Tx       */
>#define NCSI_PKT_CMD_AE		0x08 /* AEN Enable                       */
>#define NCSI_PKT_CMD_SL		0x09 /* Set Link                         */
>#define NCSI_PKT_CMD_GLS	0x0a /* Get Link                         */
>#define NCSI_PKT_CMD_SVF	0x0b /* Set VLAN Filter                  */
>#define NCSI_PKT_CMD_EV		0x0c /* Enable VLAN                      */
>#define NCSI_PKT_CMD_DV		0x0d /* Disable VLAN                     */
>#define NCSI_PKT_CMD_SMA	0x0e /* Set MAC address                  */
>#define NCSI_PKT_CMD_EBF	0x10 /* Enable Broadcast Filter          */
>#define NCSI_PKT_CMD_DBF	0x11 /* Disable Broadcast Filter         */
>#define NCSI_PKT_CMD_EGMF	0x12 /* Enable Global Multicast Filter   */
>#define NCSI_PKT_CMD_DGMF	0x13 /* Disable Global Multicast Filter  */
>#define NCSI_PKT_CMD_SNFC	0x14 /* Set NCSI Flow Control            */
>#define NCSI_PKT_CMD_GVI	0x15 /* Get Version ID                   */
>#define NCSI_PKT_CMD_GC		0x16 /* Get Capabilities                 */
>#define NCSI_PKT_CMD_GP		0x17 /* Get Parameters                   */
>#define NCSI_PKT_CMD_GCPS	0x18 /* Get Controller Packet Statistics */
>#define NCSI_PKT_CMD_GNS	0x19 /* Get NCSI Statistics              */
>#define NCSI_PKT_CMD_GNPTS	0x1a /* Get NCSI Pass-throu Statistics   */
>#define NCSI_PKT_CMD_GPS	0x1b /* Get package status               */
>#define NCSI_PKT_CMD_OEM	0x50 /* OEM                              */
>#define NCSI_PKT_CMD_PLDM	0x51 /* PLDM request over NCSI over RBT  */
>#define NCSI_PKT_CMD_GPUUID	0x52 /* Get package UUID                 */
>
