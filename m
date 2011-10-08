From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops.
Date: Sat, 8 Oct 2011 10:22:26 +0300
Message-ID: <CAOMsUMKcd-Xg0uezvknBFLCYx7U9PuKpgfHdKw8vjVvmbH6KoQ@mail.gmail.com>
References: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com> <20111007092445.4f097ed9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111007092445.4f097ed9@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 7, 2011 at 7:24 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Fri, =A07 Oct 2011 18:20:49 +0300
> Mihai Maruseac <mihai.maruseac@gmail.com> wrote:
>
>> Instead of using the dev->next chain and trying to resync at each ca=
ll to
>> dev_seq_start, use this hash and store bucket number and bucket offs=
et in
>> seq->private field.
>>
>> Tests revealed the following results for ifconfig > /dev/null
>> =A0 =A0 =A0 * 1000 interfaces:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 0.114s without patch
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 0.020s with patch
>> =A0 =A0 =A0 * 3000 interfaces:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 0.489s without patch
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 0.048s with patch
>> =A0 =A0 =A0 * 5000 interfaces:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 1.363s without patch
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 0.131s with patch
>>
>> As one can notice the improvement is of 1 order of magnitude.
>
> Good idea,
> This will change the ordering of entries in /proc which may upset
> some program, not a critical flaw but worth noting.
>
> Rather than recording the bucket and offset of last entry, another
> alternative would be to just record the ifindex.
>
> Also ifconfig is considered deprecated and replaced by ip commands
> for general use.
>

Thanks,
This is a patch from a series of improvements to both the ifconfig and
ip commands. The ip part will come later, after being properly
implemented and tested.

--=20
Mihai
