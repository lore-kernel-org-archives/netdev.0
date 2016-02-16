From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: Query regarding GTP-U code implementation in upstream linux
 kernel
Date: Tue, 16 Feb 2016 09:22:30 +0100
Message-ID: <56C2DC46.901@tpip.net>
References: <OF611F346A.45AF9DB0-ON65257F5B.002B5962-65257F5B.002B5964@tcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Partha Datta <partha.datta@tcs.com>,
	Deepankar Gupta <deepankar.gupta@tcs.com>,
	openbsc@lists.osmocom.org
To: Niti Rohilla <niti.rohilla@tcs.com>, netdev@vger.kernel.org,
	aschultz@travelping.com, hwelte@sysmocom.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:45881 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115AbcBPIbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 03:31:55 -0500
In-Reply-To: <OF611F346A.45AF9DB0-ON65257F5B.002B5962-65257F5B.002B5964@tcs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Niti,

On 02/16/2016 08:53 AM, Niti Rohilla wrote:
> Hi All,
>
> I want to enable GTP-U in OpenVswitch. I have implemented the code for the GTP-U in ovs and submitted the same on ovs-dev.
>
> As currently, GTP-U support is not available in upstream linux kernel, so to create a GTP port in ovs we have to load the openvswitch kernel
> module to linux kernel.
>
> I have received some review comments stating that first I have to implement the code for GTP-U in upstream linux kernel in netdev net-next
> tree then it can be incorporated into ovs.
>
> I want to know the process of how to implement and get the code for GTP-U into upstream linux kernel.
>
> If anybody is working on the same how can I help them to get it in into the upstream linux kernel quickly.

I'm a bit out of touch with OVS, so my idea on how this should work might be wrong.
As far as I understand OVS, the way forward would be to use the lwtunnel infrastructure to enable OVS to use a kernel GTP module.

Our current OVS module ([1], [2]) is not (yet) using lwtunnel, but we do plan on switching to that.

So far, we have been coordinating the GTP kernel module development on the OpenBSC ML [3]. The goal is to upstream it as soon as all the 
basics are covered (smallish netlink API changes, final touches on IPv6 and maybe lwtunnel).

On the OVS side, someone would then need to implement the necessary ops to handle GTP lwtunnel integration.

Andreas

[1]: http://git.osmocom.org/osmo-gtp-kernel
[2]: https://github.com/RoadRunnr/osmo-ggsn
[3]: https://lists.osmocom.org/mailman/listinfo/openbsc

>
>
> Thanks & Regards
> Niti Rohilla
>
> =====-----=====-----=====
> Notice: The information contained in this e-mail
> message and/or attachments to it may contain
> confidential or privileged information. If you are
> not the intended recipient, any dissemination, use,
> review, distribution, printing or copying of the
> information contained in this e-mail message
> and/or attachments to it are strictly prohibited. If
> you have received this communication in error,
> please notify us by reply e-mail or telephone and
> immediately and permanently delete the message
> and any attachments. Thank you
>
