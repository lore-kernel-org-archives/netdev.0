From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: 2.6.4 e100 NAPI - dst cache overflow and network unavailability
Date: Tue, 13 Apr 2004 15:06:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16507.58836.330646.613359@robur.slu.se>
References: <4075F218.90804@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Christopher Chan <cchan@outblaze.com>
In-Reply-To: <4075F218.90804@outblaze.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Christopher Chan writes:

 > However, I had NAPI enabled in the e100 driver then.
 > 
 > Turning NAPI off for the e100 driver has meant that the box has now been 
 > up several days without any problems under heavy network load.
 > 
 > I have not tried out 2.6.5 with NAPI enabled but 2.6.5 without NAPI 
 > enabled is stable.


 dst cache overflows when garbage collection cannot keep up dst entries
 freed so we exceed max_size. GC is run after gc_min_interval and eventually 
 a RCU delay which we have discussed here and are looking into now.

 So if you increase your network performance/load for any reason so more 
 dst entries are freed you can reach the overflow threshold. This is probably 
 what happens for you with NAPI driver.

 You can try to decrease gc_min_interval a bit but if you are unlucky you 
 have run into RCU problem as well. There is one experimental patch that 
 seems help.

 Tuning just to avoid dst cache overflows can mean you sacrifice a lot of
 network performance. Anyway monitor your route cache to start with. There 
 is interesting stats in /proc/net/rt_cache_stat. The rtstat utility can
 be handy parsing it.

 Cheers.
						--ro
 
 
