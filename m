From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: Re: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Fri, 14 Oct 2011 15:20:40 +0300
Message-ID: <CAOMsUMKWzKNNR-cDK7eSK-+F-hhCc8BhkzrpLHRs2tsmjXxdXw@mail.gmail.com>
References: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
 <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com> <20111012085024.634281a2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111012085024.634281a2@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2011 at 6:50 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Wed, 12 Oct 2011 12:57:26 +0300
> Mihai Maruseac <mihai.maruseac@gmail.com> wrote:
>
> It looks like you lost the ability to seek back and read the header
> (start token). =A0How is the header handled, is possible to rewind
> the file and read it over again?

We tested with a simple program reading a part of the /proc file and
then doing a seek to the start and rereading. It worked with latest
submitted patch.

>> +static inline struct net_device *next_dev(struct seq_file *seq, lof=
f_t *pos)
>> +{
>> + =A0 =A0 struct dev_iter_state *state =3D seq->private;
>> + =A0 =A0 struct net *net =3D seq_file_net(seq);
>> + =A0 =A0 struct net_device *dev =3D NULL;
>> + =A0 =A0 loff_t off;
>> +
>> + =A0 =A0 ++*pos;
>> + =A0 =A0 dev =3D dev_get_by_index_rcu(net, state->ifindex);
>
> Looks good a couple of minor nits.
>
> 1. The function should not be inline, since it is in no way performan=
ce
> =A0 critical. The compiler will probably inline it anyway.
>
> 2. dev does not have to be initialized since it is assigned a few
> =A0 lines later. =A0Most programmers are trained now to always initia=
lize
> =A0 variables, but often it is unnecessary.
>
> 3. The name next_dev() is a little generic; maybe a better name.
>

=46ixed all of them,

Thanks,
--=20
Mihai
