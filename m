From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] ethtool : Add option -L | --set-common to set common flags.
Date: Mon, 17 Jan 2011 18:17:41 -0800
Message-ID: <AANLkTiko=12CLgG_MMPshfwSRt7mZA+3DW+GRtxhaxh=@mail.gmail.com>
References: <1294963892-11997-1-git-send-email-maheshb@google.com>
	<1295039984.5386.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:10389 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309Ab1ARCRo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 21:17:44 -0500
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p0I2HhNl023651
	for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 18:17:43 -0800
Received: from bwg12 (bwg12.prod.google.com [10.188.7.12])
	by hpaq6.eem.corp.google.com with ESMTP id p0I2HUaC016359
	for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 18:17:42 -0800
Received: by bwg12 with SMTP id 12so3043677bwg.23
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 18:17:42 -0800 (PST)
In-Reply-To: <1295039984.5386.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 1:19 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2011-01-13 at 16:11 -0800, Mahesh Bandewar wrote:
>> This patch adds -L | --set-common option to add / remove common flag=
s which
>> includes loopback flag. The -l | --show-common displays the current =
values
>> for these common flags.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> =C2=A0ethtool-copy.h | =C2=A0 =C2=A01 +
>> =C2=A0ethtool.8 =C2=A0 =C2=A0 =C2=A0| =C2=A0 16 ++++++++++
>> =C2=A0ethtool.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 90 ++++++++++++++++++++=
++++++++++++++++++++++++++++++++++-
>> =C2=A03 files changed, 105 insertions(+), 2 deletions(-)
>>
>> diff --git a/ethtool-copy.h b/ethtool-copy.h
>> index 75c3ae7..5fd18c7 100644
>> --- a/ethtool-copy.h
>> +++ b/ethtool-copy.h
>> @@ -309,6 +309,7 @@ struct ethtool_perm_addr {
>> =C2=A0 * flag differs from the read-only value.
>> =C2=A0 */
>> =C2=A0enum ethtool_flags {
>> + =C2=A0 =C2=A0 ETH_FLAG_LOOPBACK =C2=A0 =C2=A0 =C2=A0 =3D (1 << 2),=
 =C2=A0 =C2=A0 /* Loopback enable / disable */
>> =C2=A0 =C2=A0 =C2=A0 ETH_FLAG_TXVLAN =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 (1 << 7), =C2=A0 =C2=A0 /* TX VLAN offload enabled */
>> =C2=A0 =C2=A0 =C2=A0 ETH_FLAG_RXVLAN =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 (1 << 8), =C2=A0 =C2=A0 /* RX VLAN offload enabled */
>> =C2=A0 =C2=A0 =C2=A0 ETH_FLAG_LRO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D (1 << 15), =C2=A0 =C2=A0/* LRO is enabled */
>> diff --git a/ethtool.8 b/ethtool.8
>> index 1760924..cf7128f 100644
>> --- a/ethtool.8
>> +++ b/ethtool.8
>> @@ -174,6 +174,13 @@ ethtool \- Display or change ethernet card sett=
ings
>> =C2=A0.B2 txvlan on off
>> =C2=A0.B2 rxhash on off
>>
>> +.B ethtool \-l|\-\-show\-common
>> +.I ethX
>> +
>> +.B ethtool \-L|\-\-set\-common
>> +.I ethX
>> +.B2 loopback on off
>> +
>> =C2=A0.B ethtool \-p|\-\-identify
>> =C2=A0.I ethX
>> =C2=A0.RI [ N ]
>> @@ -406,6 +413,15 @@ Specifies whether TX VLAN acceleration should b=
e enabled
>> =C2=A0.A2 rxhash on off
>> =C2=A0Specifies whether receive hashing offload should be enabled
>> =C2=A0.TP
>> +.B \-l \-\-show\-common
>> +Queries the specified ethernet device for common flag settings.
>> +.TP
>> +.B \-L \-\-set\-common
>> +Changes the common parameters of the specified ethernet device.
>> +.TP
>> +.A2 loopback on off
>> +Specifies whether loopback should be enabled.
>> +.TP
>
> I've just gone through the manual page and changed 'ethernet device' =
to
> 'network device' for all generic operations; please follow that. =C2=A0=
The
> source for the manual page was also renamed to ethtool.8.in as it now
> goes through autoconf substitution.
>
OK. I'll make those changes.

>> =C2=A0.B \-p \-\-identify
>> =C2=A0Initiates adapter-specific action intended to enable an operat=
or to
>> =C2=A0easily identify the adapter by sight. =C2=A0Typically this inv=
olves
>> diff --git a/ethtool.c b/ethtool.c
>> index 63e0ead..1a0c10c 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
> [...]
>> @@ -1905,6 +1932,13 @@ static int dump_offload(int rx, int tx, int s=
g, int tso, int ufo, int gso,
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> +static int dump_common_flags(int loopback)
>> +{
>> + =C2=A0 =C2=A0 fprintf(stdout, "loopback: %s\n", loopback ? "on" : =
"off");
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> =C2=A0static int dump_rxfhash(int fhash, u64 val)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 switch (fhash) {
> [...]
>> @@ -2219,6 +2257,53 @@ static int do_scoalesce(int fd, struct ifreq =
*ifr)
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> +static int do_gcommon(int fd, struct ifreq *ifr)
>> +{
>> + =C2=A0 =C2=A0 struct ethtool_value eval;
>> + =C2=A0 =C2=A0 int loopback =3D 0;
>> +
>> + =C2=A0 =C2=A0 fprintf(stdout, "Common flags for %s:\n", devname);
>> +
>> + =C2=A0 =C2=A0 eval.cmd =3D ETHTOOL_GFLAGS;
>> + =C2=A0 =C2=A0 ifr->ifr_data =3D (caddr_t)&eval;
>> + =C2=A0 =C2=A0 if (ioctl(fd, SIOCETHTOOL, ifr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 perror("Cannot get devic=
e flags");
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 loopback =3D (eval.data =
& ETH_FLAG_LOOPBACK) !=3D 0;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return dump_common_flags(loopback);
>
> Breaking up a bitmask into a list of flag parameters is fairly
> pointless. =C2=A0I realise do_goffload() and dump_offload() do that b=
ut I am
> just waiting for Micha=C5=82 Miros=C5=82aw's changes to offload flags=
 to be
> settled before I fix them.
>
>> +}
>> +
>> +static int do_scommon(int fd, struct ifreq *ifr)
>> +{
>> + =C2=A0 =C2=A0 struct ethtool_value eval;
>> +
>> + =C2=A0 =C2=A0 if (common_flags_mask) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.cmd =3D ETHTOOL_GFL=
AGS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.data =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ifr->ifr_data =3D (caddr=
_t)&eval;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ioctl(fd, SIOCETHTOO=
L, ifr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 perror("Cannot get device common flags");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return 1;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.cmd =3D ETHTOOL_SFL=
AGS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.data =3D
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((eval.dat=
a & ~(common_flags_mask | off_flags_mask)) |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(com=
mon_flags_wanted | off_flags_wanted));
>
> Why should this use off_flags_mask and off_flags_wanted? =C2=A0They s=
hould
> both be 0 if this function is called.
>
That is right! Actually the get (ETHTOOL_GFLAGS) operation confused
me. I thought the values are fetched and *preserved* while setting the
new value. But when looked at it carefully, that is not the case.
Actually why that ioctl() with ETHTOOL_GFLAGS required?

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ioctl(fd, SIOCETHTOO=
L, ifr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 perror("Cannot set device common flags");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return 1;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fprintf(stdout, "No comm=
on settings changed\n");
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> =C2=A0static int do_goffload(int fd, struct ifreq *ifr)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct ethtool_value eval;
>> @@ -2407,8 +2492,9 @@ static int do_soffload(int fd, struct ifreq *i=
fr)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.cmd =3D ETHTOO=
L_SFLAGS;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.data =3D ((eval.dat=
a & ~off_flags_mask) |
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0off_flags_wanted);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eval.data =3D
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((eval.dat=
a & ~(off_flags_mask | common_flags_mask)) |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(off=
_flags_wanted | common_flags_wanted));
>
> Similarly, why should this use common_flags_mask and
> common_flags_wanted?

=46or the same (wrong) reason mentioned above. I'll correct it and post
the new patch.

Thanks,
--mahesh..
>
> Ben.
>
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D ioctl(fd, S=
IOCETHTOOL, ifr);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (err) {
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
