From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Thu, 14 Jan 2010 10:32:18 -0800
Message-ID: <4B4F6332.50606@candelatech.com>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1263481549.23480.24.camel@bigi>
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

On 01/14/2010 07:05 AM, jamal wrote:
>
> Ive had an equivalent discussion with B Greear (CCed) at one point on
> something similar, curious if you solve things differently - couldnt
> tell from the patch if you address it.
> Comments inline:
>
> On Thu, 2010-01-14 at 15:05 +0100, Patrick McHardy wrote:
>> The attached largish patch adds support for "conntrack zones",
>> which are virtual conntrack tables that can be used to seperate
>> connections from different zones, allowing to handle multiple
>> connections with equal identities in conntrack and NAT.
>>
>> A zone is simply a numerical identifier associated with a network
>> device that is incorporated into the various hashes and used to
>> distinguish entries in addition to the connection tuples. Additionally
>> it is used to seperate conntrack defragmentation queues. An iptables
>> target for the raw table could be used alternatively to the network
>> device for assigning conntrack entries to zones.
>>
>>
>> This is mainly useful when connecting multiple private networks using
>> the same addresses (which unfortunately happens occasionally)
>
> Agreed that this would be a main driver of such a feature.
> Which means that you need zones (or whatever noun other people use) to
> work on not just netfilter, but also routing, ipsec etc.
> As a digression: this is trivial to solve with network namespaces.

For small or simple cases, this may be true..but there is a lot of work
to make a complex user-space app that manages arbitrary amounts of interfaces
routing tables in an arbitrary amount of network namespaces.  With the contrack-zones
approach, user-space apps do not require any significant changes, and you do not
need the rest of the namespace overhead to accomplish the task.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
