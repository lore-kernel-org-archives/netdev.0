From: "Bhanu Prakash Gollapudi" <bprakash-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next-2.6 v3] net: consolidate and fix
 ethtool_ops->get_settings calling
Date: Mon, 5 Sep 2011 23:52:22 -0700
Message-ID: <4E65C326.3010506@broadcom.com>
References: <1314905304-16485-1-git-send-email-jpirko@redhat.com>
	<20110902122630.GC1991@minipsycho>
	<1314989161.3419.5.camel@bwh-desktop>
	<20110903133428.GA2821@minipsycho> <1315057614.3092.160.camel@deadeye>
	<5A9BD224CEA58D4CB62235967D650C160A1B7D1C@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "amit.salecha-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <amit.salecha-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	"bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	"JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"decot-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <decot-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
	"therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org" <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	"xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	"Duyck, Alexander H" <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org" <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	"greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org" <greearb-my8/4N5VtI6/mCGcgd5LIw@public.gmane.org
To: "Zou, Yi" <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <5A9BD224CEA58D4CB62235967D650C160A1B7D1C-osO9UTpF0UQd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/5/2011 8:25 PM, Zou, Yi wrote:
>>
>> On Sat, 2011-09-03 at 15:34 +0200, Jiri Pirko wrote:
>>> This patch does several things:
>>> - introduces __ethtool_get_settings which is called from ethtool code
>> and
>>>    from drivers as well. Put ASSERT_RTNL there.
>>> - dev_ethtool_get_settings() is replaced by __ethtool_get_settings()
>>> - changes calling in drivers so rtnl locking is respected. In
>>>    iboe_get_rate was previously ->get_settings() called unlocked. This
>>>    fixes it. Also prb_calc_retire_blk_tmo() in af_packet.c had the same
>>>    problem. Also fixed by calling __dev_get_by_index() instead of
>>>    dev_get_by_index() and holding rtnl_lock for both calls.
>>> - introduces rtnl_lock in bnx2fc_vport_create() and fcoe_vport_create()
>>>    so bnx2fc_if_create() and fcoe_if_create() are called locked as they
>>>    are from other places.
>>> - use __ethtool_get_settings() in bonding code
>>>
>>> Signed-off-by: Jiri Pirko<jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Reviewed-by: Ben Hutchings<bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>  [except FCoE bits]
>>
>> Ben.
> FCoE bits look ok to me. Thanks,
>
> Reviewed-by: Yi Zou<yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

bnx2fc changes looks OK to me.
Reviewed-by: Bhanu Prakash Gollapudi <bprakash-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>
>>
>> --
>> Ben Hutchings, Staff Engineer, Solarflare
>> Not speaking for my employer; that's the marketing department's job.
>> They asked us to note that Solarflare product names are trademarked.
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
