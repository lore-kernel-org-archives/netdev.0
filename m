From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH v2 00/11] Add network namespace support in the RDMA-CM
Date: Tue, 21 Apr 2015 09:11:57 -0500
Message-ID: <55365AAD.6020100@opengridcomputing.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com> <553512FA.1040708@opengridcomputing.com> <5535EFE9.3000106@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5535EFE9.3000106-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/21/2015 1:36 AM, Haggai Eran wrote:
> On 20/04/2015 17:53, Steve Wise wrote:
>> Hey Haggai,
>>
>> Did you check for changes needed in drivers/infiniband/core/iwcm.c?
> We focused on namespace support for InfiniBand alone in this series. We
> didn't handle iWARP, nor did we implement support for RoCE or other
> transports.
>
>> I notice that it uses init_net here:
>>
>> static int __init iw_cm_init(void)
>> {
>>          iwcm_wq = create_singlethread_workqueue("iw_cm_wq");
>>          if (!iwcm_wq)
>>                  return -ENOMEM;
>>
>>          iwcm_ctl_table_hdr = register_net_sysctl(&init_net, "net/iw_cm",
>>                                                   iwcm_ctl_table);
>>          if (!iwcm_ctl_table_hdr) {
>>                  pr_err("iw_cm: couldn't register sysctl paths\n");
>>                  destroy_workqueue(iwcm_wq);
>>                  return -ENOMEM;
>>          }
>>
>>          return 0;
>> }
>>
> I see the only thing in the iWARP sysctl registered here is the default
> backlog. If you want to control this parameter per namespace, we could
> store it per network namespace, and add a namespace parameter to
> iw_cm_listen. I'm not sure how important this is though.

I don't think it needs to be per namespace, as long as it still applies 
across all name spaces.

Steve.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
