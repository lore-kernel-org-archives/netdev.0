From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] openvswitch: Add Kconfig dependency on GRE-DEMUX.
Date: Fri, 28 Jun 2013 12:29:59 -0700
Message-ID: <CALnjE+oYja6ftYXOdkVbLQNfLb0TqbiDi0ucrtEQpbR-Mnu0ww@mail.gmail.com>
References: <1372444222-29379-1-git-send-email-pshelar@nicira.com>
	<1372445692.1937.27.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org, rdunlap@infradead.org,
	Jesse Gross <jesse@nicira.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:60203 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751725Ab3F1TaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 15:30:00 -0400
Received: by mail-qe0-f49.google.com with SMTP id cz11so819025qeb.8
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 12:29:59 -0700 (PDT)
In-Reply-To: <1372445692.1937.27.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 11:54 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2013-06-28 at 11:30 -0700, Pravin B Shelar wrote:
>> Openvswitch uses function from NET_IPGRE_DEMUX module.
>> Add Kconfig dependency to fix compilation errors.
>
> That's not an obvious dependency, and this may result in OPENVSWITCH
> being inexplicably disabled when people update their custom kernel
> configs.
>
> Either OPENVSWITCH should select NET_IPGRE_DEMUX, or the code should be
> fixed to work without it.  I don't know what the breakage was but I
> would guess that you could use an automatic config symbol like:
>
This is breakage: http://marc.info/?l=linux-netdev&m=137244035226634&w=2


> bool OPENVSWITCH_IPGRE_SUPPORT
>         depends on OPENVSWITCH && NET_IPGRE_DEMUX && !(OPENVSWITCH=y && NET_IPGRE_DEMUX=m)
>
I will use select to resolve dependency rather than another config
symbol for ovs-gre.

> Ben.
>
>> CC: Jesse Gross <jesse@nicira.com>
>> Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> Signed-off-by: Pravin Shelar <pshelar@nicira.com>
>> ---
>>  net/openvswitch/Kconfig     |    1 +
>>  net/openvswitch/vport-gre.c |    2 --
>>  net/openvswitch/vport.c     |    3 ---
>>  3 files changed, 1 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
>> index 9fbc04a..9fc0df2 100644
>> --- a/net/openvswitch/Kconfig
>> +++ b/net/openvswitch/Kconfig
>> @@ -4,6 +4,7 @@
>>
>>  config OPENVSWITCH
>>       tristate "Open vSwitch"
>> +     depends on NET_IPGRE_DEMUX
>>       ---help---
>>         Open vSwitch is a multilayer Ethernet switch targeted at virtualized
>>         environments.  In addition to supporting a variety of features
>> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
>> index 943e5c4..21d5073 100644
>> --- a/net/openvswitch/vport-gre.c
>> +++ b/net/openvswitch/vport-gre.c
>> @@ -16,7 +16,6 @@
>>   * 02110-1301, USA
>>   */
>>
>> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
>>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>>
>>  #include <linux/if.h>
>> @@ -271,4 +270,3 @@ const struct vport_ops ovs_gre_vport_ops = {
>>       .get_name       = gre_get_name,
>>       .send           = gre_tnl_send,
>>  };
>> -#endif
>> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
>> index ba81294..ba240a8 100644
>> --- a/net/openvswitch/vport.c
>> +++ b/net/openvswitch/vport.c
>> @@ -38,10 +38,7 @@
>>  static const struct vport_ops *vport_ops_list[] = {
>>       &ovs_netdev_vport_ops,
>>       &ovs_internal_vport_ops,
>> -
>> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
>>       &ovs_gre_vport_ops,
>> -#endif
>>  };
>>
>>  /* Protected by RCU read lock for reading, ovs_mutex for writing. */
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
