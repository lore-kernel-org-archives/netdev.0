From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Filter inet dgram sockets with established
 state by default
Date: Thu, 15 Jan 2015 06:49:30 +0200
Message-ID: <CAMw6YJLhLiB_0G_Gkcj-E2-ec=d+J-esTLGKccKyWQ3WXcA8-w@mail.gmail.com>
References: <1420738342-3750-1-git-send-email-vadim4j@gmail.com>
	<20150113173150.0a50f74e@urahara>
	<20150114064944.GA28611@angus-think.lan>
	<20150114144120.0e15ac1f@urahara>
	<20150114224347.GA14983@angus-think.lan>
	<20150114184806.56a7b7e2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:42619 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbbAOEtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 23:49:31 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so32493943wib.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 20:49:30 -0800 (PST)
In-Reply-To: <20150114184806.56a7b7e2@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So it means showing by established state by default.

On Thu, Jan 15, 2015 at 4:48 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 15 Jan 2015 00:43:47 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
>
>> On Wed, Jan 14, 2015 at 02:41:20PM -0800, Stephen Hemminger wrote:
>> > On Wed, 14 Jan 2015 08:49:44 +0200
>> > Vadim Kochan <vadim4j@gmail.com> wrote:
>> >
>> > > On Tue, Jan 13, 2015 at 05:31:50PM -0800, Stephen Hemminger wrote:
>> > > > On Thu,  8 Jan 2015 19:32:22 +0200
>> > > > Vadim Kochan <vadim4j@gmail.com> wrote:
>> > > >
>> > > > > From: Vadim Kochan <vadim4j@gmail.com>
>> > > > >
>> > > > > As inet dgram sockets (udp, raw) can call connect(...)  - they
>> > > > > might be set in ESTABLISHED state. So keep the original behaviour of
>> > > > > 'ss' which filtered them by ESTABLISHED state by default. So:
>> > > > >
>> > > > >     $ ss -u
>> > > > >
>> > > > >     or
>> > > > >
>> > > > >     $ ss -w
>> > > > >
>> > > > > Will show only ESTABLISHED UDP sockets by default.
>> > > > >
>> > > > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>> > > > > ---
>> > > > >  misc/ss.c | 4 ++--
>> > > > >  1 file changed, 2 insertions(+), 2 deletions(-)
>> > > > >
>> > > > > diff --git a/misc/ss.c b/misc/ss.c
>> > > > > index 08d210a..015d829 100644
>> > > > > --- a/misc/ss.c
>> > > > > +++ b/misc/ss.c
>> > > > > @@ -170,11 +170,11 @@ static const struct filter default_dbs[MAX_DB] = {
>> > > > >               .families = (1 << AF_INET) | (1 << AF_INET6),
>> > > > >       },
>> > > > >       [UDP_DB] = {
>> > > > > -             .states   = (1 << SS_CLOSE),
>> > > > > +             .states   = (1 << SS_ESTABLISHED),
>> > > > >               .families = (1 << AF_INET) | (1 << AF_INET6),
>> > > > >       },
>> > > > >       [RAW_DB] = {
>> > > > > -             .states   = (1 << SS_CLOSE),
>> > > > > +             .states   = (1 << SS_ESTABLISHED),
>> > > > >               .families = (1 << AF_INET) | (1 << AF_INET6),
>> > > > >       },
>> > > > >       [UNIX_DG_DB] = {
>> > > >
>> > > > This is a change likely to break somebody using 'ss -u' now and the bound
>> > > > sockets will disappear from the output.
>> > > >
>> > >
>> > > But thats was as original behaviour before I added table-driven code
>> > > (about few commits ago), so thats a rather fix (sorry I did not noticed
>> > > about it) to keep the previous behaviour for dgram sockets - show
>> > > established states by default.
>> > >
>> > > Regards,
>> >
>> > Ok, I will merge it and update the comments.
>> Even with this PATCH I am still confused what is preferred behaviour -
>> show established dgram sockets (as it was all the way) or closed + established by default.
>>
>> What do you think ?
>>
>> Thanks,
>
> Make it work like earliest releases (like 3 months ago).
