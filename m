From: "=?ISO-8859-1?Q?Mart=EDn_Ferrari?=" <martin.ferrari@gmail.com>
Subject: Re: IFF_PROMISC again
Date: Sun, 27 May 2007 22:05:01 -0300
Message-ID: <b9800b70705271805h4613ad14u33b754d12b80af34@mail.gmail.com>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
	 <465385F2.7080309@candelatech.com>
	 <b9800b70705252328x6318c85es922e81662ce41762@mail.gmail.com>
	 <20070527094923.3b4705b6@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ben Greear" <greearb@candelatech.com>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:16728 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbXE1BFC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 21:05:02 -0400
Received: by nz-out-0506.google.com with SMTP id n1so761723nzf
        for <netdev@vger.kernel.org>; Sun, 27 May 2007 18:05:01 -0700 (PDT)
In-Reply-To: <20070527094923.3b4705b6@freepuppy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen, I think your mail didn't make it to netdev. Majordomo seems
to be working badly with special charsets (my mails used to be totally
ignored because of charset and/or encoding issues).

On 5/27/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> > Wow, I searched for this a lot! It could be all I need, although it
> > doesn't seem very robust to look at the bitmap driectly, is it?
> >
> > Maybe it would be cleaner to add an "promiscuity" file to that stru=
cture?

> /sys/class/net/ethX/flags was an interface mistake. Don't depend on i=
t.
>
> I added it back when sysfs was first starting. Most of the files in /=
sys/class/net/ethX
> are really meant only for debugging. There was no debugfs at the time=
=2E
>
> The problem is it exports bit values as ABI that shouldn't be nailed =
down.

Great that you point it out. Then, we're back to the initial
situation, there is no reliable way of polling promisc state, and I am
looking for a way to do that. Ways I think it could be done:

- Exporting /sys/class/net/ethX/promiscuity as a counter (I have a
working patch for this)
- Exporting /sys/class/net/ethX/promisc as a binary value, from dev->fl=
ags.
- ORing the two IFF_PROMISC flags in dev_get_flags() (the patch I sent)
- Dropping gflags altogether, as there doesn't seem to be any real use
case for it, and keep using dev_get_flags().

Any suggestion?

--=20
Mart=EDn Ferrari
