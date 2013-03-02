From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: Re: [PATCH RESEND 3/3] e1000e: fix accessing to
 suspended device
Date: Sat, 02 Mar 2013 16:26:38 +0400
Message-ID: <5131EFFE.4010700@openvz.org>
References: <20130225051010.12689.28611.stgit@zurg>
	<20130225051911.12689.11167.stgit@zurg>
	<512C0B59.4020209@intel.com> <512C8889.80107@openvz.org>
	<1361921710.2996.19.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1361921710.2996.19.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> On Tue, 2013-02-26 at 14:03 +0400, Konstantin Khlebnikov wrote:
>> Waskiewicz Jr, Peter P wrote:
>>> On 2/24/2013 9:19 PM, Konstantin Khlebnikov wrote:
>>>> This patch fixes some annoying messages like 'Error reading PHY register' and
>>>> 'Hardware Erorr' and saves several seconds on reboot.
>>>
>>> Any networking-related patches should also include netdev@vger.kernel.org.
>>
>> Yeah, I forgot about this, since I came here from PCI-bus side, not from the network =)
>>
>>>
>>> I'm also a bit confused how the changes below match the patch description.
>>   >  Elaborating a bit more how the changes suppress the messages might be a good thing.
>>
>> Patch eliminates reason of these errors -- now driver will wake up
>> the device before accessing to its registers.
> [...]
>
> But e1000e calls netif_device_detach() when entering run-time suspend.
> That currently prevents any ethtool operations from running until it
> resumes.

This seems racy. dev_ethtool() runs under rtnl-lock, but suspend-resume
run asynchronously. Runtime-suspend shoudn't call netif_device_detach(),
logically device isn't dead it just take a nap for a while..

>
> (This is definitely a misfeature of either the ethtool core or e1000e.
> It is absolutely ridiculous that I can't check the PHY settings of an
> e1000e - or even driver information! - when the link is down.)

Ok link is down, but device still alive and I not see anything ridiculous
in checking its registers.


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
