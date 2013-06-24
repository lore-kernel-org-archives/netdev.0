From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v4 2/2] vxlan: allow specifying multiple default destinations
Date: Mon, 24 Jun 2013 08:57:55 +0300
Message-ID: <CAF1J0HOKKZhjs+M++d0LwYBYSexD9Cx84t7MUmu6Gk39PDfXrw@mail.gmail.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130623171440.439356b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog108.obsmtp.com ([74.125.245.84]:58952 "HELO
	na3sys010aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751155Ab3FXF54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 01:57:56 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so10478185obc.13
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 22:57:55 -0700 (PDT)
In-Reply-To: <20130623171440.439356b7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 3:14 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sun, 23 Jun 2013 19:22:23 +0300
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>
>> A list of multiple default destinations can be used in environments that
>> disable multicast on the infrastructure level, e.g. public clouds.
>>
>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>> ---
>>  drivers/net/vxlan.c          | 268 +++++++++++++++++++++++++++++++++++++++++--
>>  include/uapi/linux/if_link.h |  17 +++
>>  2 files changed, 276 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index e5fb6568..f57a0d94 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -103,6 +103,7 @@ struct vxlan_rdst {
>>       u32                      remote_vni;
>>       u32                      remote_ifindex;
>>       struct list_head         list;
>> +     struct rcu_head          rcu;
>>  };
>
> The use of remotes_cnt here is not SMP safe.
> You are using remotes_cnt to size the buffer for dumping, but then the list
> of remotes might change during the dump.

The remotes_cnt is used only in netlink callbacks with rtnl_lock held
and it cannot be modified otherwise, so I don't see why it is not SMP
safe.

> There a a couple of alternatives here:
> 1. Put a hard limit on the number of remotes per MAC.
> 2. When there are multiple destnations, just dump multiple entries, like
>    multipath routing does.
>
> I prefer #2 because it also allows for a cleaner API on creation.
>



--
Sincerely yours,
Mike.
