From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Mon, 12 Jan 2015 20:42:24 -0800
Message-ID: <54B4A230.9000602@gmail.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: danny.zhou@intel.com, nhorman@tuxdriver.com, dborkman@redhat.com,
	john.ronciak@intel.com, hannes@stressinduktion.org,
	brouer@redhat.com, Or Gerlitz <gerlitz.or@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:46118 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbAMEmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 23:42:45 -0500
Received: by mail-ob0-f174.google.com with SMTP id uz6so781233obc.5
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 20:42:45 -0800 (PST)
In-Reply-To: <20150113043509.29985.33515.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2015 08:35 PM, John Fastabend wrote:
> This patch adds net_device ops to split off a set of driver queues
> from the driver and map the queues into user space via mmap. This
> allows the queues to be directly manipulated from user space. For
> raw packet interface this removes any overhead from the kernel networ=
k
> stack.
>

+cc: Or Gerlitz

[...]

> +
> +struct tpacket_dev_info {
> +	__u16	tp_device_id;
> +	__u16	tp_vendor_id;
> +	__u16	tp_subsystem_device_id;
> +	__u16	tp_subsystem_vendor_id;
> +	__u32	tp_numa_node;
> +	__u32	tp_revision_id;
> +	__u32	tp_num_total_qpairs;
> +	__u32	tp_num_inuse_qpairs;
> +	__u32	tp_num_rx_desc_fmt;
> +	__u32	tp_num_tx_desc_fmt;
> +	struct tpacket_nic_desc_expr tp_rx_dexpr[PACKET_MAX_NUM_DESC_FORMAT=
S];
> +	struct tpacket_nic_desc_expr tp_tx_dexpr[PACKET_MAX_NUM_DESC_FORMAT=
S];

At least one reason this is still RFCs is this needs to be
cleaned up.

net/packet/af_packet.c: In function =E2=80=98packet_getsockopt=E2=80=99=
:
net/packet/af_packet.c:3918:1: warning: the frame size of 9264 bytes is=
=20
larger than 2048 bytes [-Wframe-larger-than=3D]

but I wanted to see if there was any feedback.

Thanks,
John

--=20
John Fastabend         Intel Corporation
