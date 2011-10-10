From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops.
Date: Mon, 10 Oct 2011 11:43:20 +0300
Message-ID: <CAOMsUMLRc5dT4kGyAUMLka2f=jTOCeYt8WEkNZPY+dwkrBhPeQ@mail.gmail.com>
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
>> As one can notice the improvement is of 1 order of magnitude.
>
> Good idea,
> This will change the ordering of entries in /proc which may upset
> some program, not a critical flaw but worth noting.
>
> Rather than recording the bucket and offset of last entry, another
> alternative would be to just record the ifindex.
>

I tried to record the ifindex but I think that using it and
dev_get_by_index can result in an infinite loop or a NULL
dereferrence. If a device is removed and ifindex points to it we'll
get a NULL from dev_get_by_index. Checking for NULL and calling again
dev_get_by_index will end in an infinite loop at the end of the hlist.

Augmenting the structure to also contain the number of indexes when
the seq_file is opened returns to the current situation with two ints.
Also, it is more prone to bugs caused by device removal while
printing.

--=20
Mihai
