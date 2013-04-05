From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH] mac802154: Keep track of the
 channel when changed
Date: Fri, 05 Apr 2013 17:20:23 -0400
Message-ID: <515F4017.6060404@signal11.us>
References: <1365194201-2635-1-git-send-email-alan@signal11.us>
	<20130405210514.GF28141@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20130405210514.GF28141@ws>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/05/2013 05:05 PM, Werner Almesberger wrote:
> Alan Ott wrote:
>> Prevent set_channel() from getting called every time a packet is sent. This
>> looks like it was an oversight.
> at86rf230.c and derivatives avoid this problem by setting
> phy->current_* in the *_channel function.
>
> But I'd agree that it's nicer to do this in one place, not in
> every driver.
>
> In case a driver had a weird failure mode in which it leaves the
> original channel but only makes it halfway to the new channel, it
> could still set phy->current_* and return an error. So there's no
> loss of functionality with your change.

Hmm... I just noticed that mib.c does the same thing (and doesn't set
phy->current_*). I'll need to fix that one too (and resubmit). :(

Alan.




------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
