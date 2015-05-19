From: Parav Pandit <parav.pandit-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the RDMA-CM
Date: Tue, 19 May 2015 22:09:14 +0530
Message-ID: <CAGgvQNRjSVcOfQB3bhXTdPoa04Hs7jc1+hXvL99EqDjbaaOw=A@mail.gmail.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	<1432045826.5304.6.camel@opteya.com>
	<555B4EBE.7010900@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555B4EBE.7010900-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 8:24 PM, Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wro=
te:
> On 19/05/2015 17:30, Yann Droneaud wrote:
>>Le dimanche 17 mai 2015 =C3=A0 08:50 +0300, Haggai Eran a =C3=A9crit =
:
>>> Full support for RoCE will be introduced in a later stage.
>>>
>> How does this play with iWarp: as iWarp HCA are aware of IP addresse=
s /
>> UDP/TCP ports, AFAIK, are those tied to namespace with this patchset=
 or
>> will it be possible to use the iWarp HCA to access to address/port
>> resources tied to a different namespace ?
>
> At the moment the patchset doesn't add iWarp namespace support, as I
> wrote in the discussion about v3 [1]. I suspect that the current iWar=
p
> code lets users listen in one namespace and receive requests belongin=
g
> to the init namespace, or break the namespaces in similar ways. The
> patchset doesn't attempt to fix this for iWarp or RoCE, only for Infi=
niBand.
>

This has come up during our first round of patch set for RoCEv2.
However due to last set of changes in this patch set, we decided to
move in for later submission.

Current high design approach to support this is:

A callback function registered to IP stack for IP address
assignment/removal. (it could be done possibly done for GID entry
update, instead of IP)
=46or each such namespace, for device supporting RoCEv2, one UDP socket
with RoCEv2 UDP port would be created and destroyed.



> Regards,
> Haggai
>
> [1] http://www.spinics.net/lists/linux-rdma/msg25156.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma"=
 in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
