From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 for-next 00/13] Add network namespace support in the
 RDMA-CM
Date: Thu, 14 May 2015 08:35:48 +0300
Message-ID: <55543434.4060401@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FD7B85@ORSMSX109.amr.corp.intel.com>
 <55531073.1000305@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDA13B@ORSMSX109.amr.corp.intel.com>
 <20150513171823.GB20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDA1AB@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FDA1AB-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/05/2015 20:30, Hefty, Sean wrote:
>>>>> How does network namespace support work with iWarp?
>>>>
>>>> We did not implement network namespace support for iWarp. Only for
>>>> InfiniBand. The iWarp code continues to use &init_net whenever a
>> network
>>>> namespace is needed, as it does today.
>>>
>>> We need a solution that supports both.  It's odd for the RDMA CM to
>>> support a feature only for some devices, when the solution should be
>>> general.
>>
>> Yes, it is not optimal, but given that every protocol uses a
>> completely different scheme to interact with netdev, I'm not sure
>> there is another option but to do them piecemeal?
> 
> Piecemeal isn't necessarily the problem.  No thought appears to have been given to how this scheme supports iWarp at all.  My concern is around whether any changes should be made to the ib_cm, versus keeping everything contained in the rdma_cm.  I.e. do we want the same kref schemed added to the iw_cm, or keep reference counts only in the rdma_cm?

I'm not sure iWarp should use the exact same solution we use for IB. I'm
not very familiar with iWarp CM code, but intuitively I think because
iWarp is defined on top of TCP/IP, it would make sense to attach
iw_cm_ids to namespaces, even while for ib_cm_ids you can't always do that.

The problem in IB is that ib_cm doesn't care about IP addresses so there
are cases where it cannot resolve the namespace, but in iWarp you don't
have that problem, right?

In any case, the RDMA CM code handling CM events is naturally separate
between iWarp and IB, so they don't need to use the same solution.

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
