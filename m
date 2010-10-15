From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH net-next] vmxnet3: make bit twiddle routines inline
Date: Fri, 15 Oct 2010 14:22:03 -0700
Message-ID: <AANLkTin_w2geQjW-nF4qjiPyD0=KXYswhGQE2cR-KJax@mail.gmail.com>
References: <20101015140620.63d0a615@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"David S. Miller" <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38577 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932336Ab0JOVWE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 17:22:04 -0400
Received: by qwa26 with SMTP id 26so578733qwa.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 14:22:04 -0700 (PDT)
In-Reply-To: <20101015140620.63d0a615@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 2:06 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> +static inline void set_flag_le16(__le16 *data, u16 flag)
> +{
> + =C2=A0 =C2=A0 =C2=A0 *data =3D cpu_to_le16(le16_to_cpu(*data) | fla=
g);
> +}
> +

Instead of swapping twice on BE machines, why not:

*data |=3D cpu_to_le16(flag);

Which may even get done away with at compile time if flag is a constant=
=2E

Similarly for the others.

Cheers,

Harvey
