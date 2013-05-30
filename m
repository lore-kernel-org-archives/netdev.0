From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v3 1/2] vxlan: introduce vxlan_rdst_append
Date: Thu, 30 May 2013 11:42:42 +0300
Message-ID: <CAF1J0HOZv3m08qyJuStH-zKwF1H4vWVhnRE6anorfspGzuVKeQ@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-2-git-send-email-mike.rapoport@ravellosystems.com>
	<20130529155642.391b50b3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:47797 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S967174Ab3E3Imn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 04:42:43 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so9192816obc.34
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 01:42:42 -0700 (PDT)
In-Reply-To: <20130529155642.391b50b3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 1:56 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 29 May 2013 13:00:15 +0300
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>
>> -/* Add/update destinations for multicast */
>> -static int vxlan_fdb_append(struct vxlan_fdb *f,
>> -                         __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
>> +static int vxlan_rdst_append(struct vxlan_rdst *rdst, __be32 ip, __be16 port,
>> +                          __u32 vni, __u32 ifindex)
>>  {
>>       struct vxlan_rdst *rd_prev, *rd;
>>
>>       rd_prev = NULL;
>> -     for (rd = &f->remote; rd; rd = rd->remote_next) {
>> +     for (rd = rdst; rd; rd = rd->remote_next) {
>
> The remote destinations should be using one of our nice list macros.

Can you explain why?
Current linked list implementation for multiple destinations in fdb
seems quite Ok and I've just reused it for default destinations
management...

> And what about locking? or RCU?

Oops, mu fault :)

--
Sincerely yours,
Mike.
