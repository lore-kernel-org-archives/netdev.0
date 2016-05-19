From: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
Date: Thu, 19 May 2016 20:13:30 +0300
Message-ID: <CAKHjkjnxeLfaZ-=_60ka+gNiX90Rtkkwj2Q-UJ5_5Z9DWAeOSg@mail.gmail.com>
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
	<CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
	<b4a8c4ca-74c5-b9b4-f9a5-4386cf6857fe@redhat.com>
	<CALzJLG8ho88yJStHbPg+XFtEJHDQf3s20gjnsEdRdh4mGye7FQ@mail.gmail.com>
	<79e8e8c2-6905-e9c4-b817-f5d5a21b8873@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Linux Netdev List <netdev@vger.kernel.org>,
	ophirm@mellanox.com, Eran Ben Elisha <eranbe@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38518 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932405AbcESRNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:13:31 -0400
Received: by mail-wm0-f49.google.com with SMTP id n129so45735183wmn.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 10:13:31 -0700 (PDT)
In-Reply-To: <79e8e8c2-6905-e9c4-b817-f5d5a21b8873@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Doug,
Attaching here a response from Ophir Maor (from Mellanox community)

>
> Read your own guides ;-).
>
> I'm using this one for your switches:
> https://community.mellanox.com/docs/DOC-1417
>
> And these to try and get the linux machines configured properly:
> https://community.mellanox.com/docs/DOC-1414
> https://community.mellanox.com/docs/DOC-1415
> https://community.mellanox.com/docs/DOC-2311
> https://community.mellanox.com/docs/DOC-2474
> http://www.mellanox.com/related-docs/prod_software/RoCE_with_Priority_Flow_Control_Application_Guide.pdf
>
> The guides are helpful if your setup allows you to follow their exact
> example.  But, they are shy on information about how to modify the
> examples to your specific situation.  For instance, I have to use vlan
> priority 5 as my no-drop priority for RoCE traffic.  I can't reliably
> tell which portions of the guide I must switch the 3s to 5s in order to
> get the new priority, and which uses of 3s in the guides relate to other
> things that could be mapped to 5.  On a separate note, it's unclear to
> me if your switches and cards support more than one no-drop priority
> (other vendor's RoCE cards I'm using here don't, they only allow one
> no-drop priority for RoCE traffic and it must be 5).  If it does support
> more than one, I'd actually like both 3 and 5 to be no-drop and for one
> vlan to use 3 and another to use 5.

There are two flows to configure egress mapping

- flow that pass via the kernel. Then you need to use kernel commands
(e.g. vconfig set_egress_map, or other commands) to make the kernel
set the egress priority.

- flows that bypass the kernel such as RoCE, then you need to use
tc_wrap to set the egress mapping.

This post explains it very nicely for ConnectX-4.

https://community.mellanox.com/docs/DOC-2474

Thanks,

Ophir.
