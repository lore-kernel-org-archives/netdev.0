From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work
Date: Tue, 11 Dec 2007 10:33:45 +0300
Message-ID: <475E3D59.10804@sw.ru>
References: <20071210163645.GA24030@iris.sw.ru>
	<m1prxd28h3.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1prxd28h3.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> The idea of separate structures make sense, and seems needed and useful.
> 
> "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> 
>> diff --git a/include/net/netns/unix.h b/include/net/netns/unix.h
>> new file mode 100644
>> index 0000000..27b4e7f
>> --- /dev/null
>> +++ b/include/net/netns/unix.h
>                    ^^^^^^
> Given that we are making this per protocol adding a separate directory
> to hold them seems to be the wrong grouping.  Ideally we want everything
> for the protocol all together in the same location so it is easy
> to find.  Possibly with a user/kernel split.
> 
> So perhaps unix_net.h
The idea was simple:
- I can name 5 files right now
- I want them to be shown to gather by ls
- so, there are 2 ways, namely:
  # include/net/netns/unix.h
  # include/net/netns-unix.h

Regards,
	Den

> 
>> @@ -0,0 +1,13 @@
>> +/*
>> + * Unix network namespace
>> + */
>> +#ifndef __NETNS_UNIX_H__
>> +#define __NETNS_UNIX_H__
>> +
>> +struct ctl_table_header;
>> +struct netns_unix {
>> +	int			sysctl_unix_max_dgram_qlen;
>> +	struct ctl_table_header	*unix_ctl;
>> +};
> 
> How about struct unix_net?  I think that tracks a little better
> with how we have done struct in_device, ip6_dev and their friends.
> 
> Eric
> 
