From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 2.6 sis900 (and tlan?) multicast bug
Date: Mon, 26 Jan 2004 17:22:41 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40159331.80808@pobox.com>
References: <20040126204215.GA25578@rivenstone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joseph Fannin <jhf@rivenstone.net>
In-Reply-To: <20040126204215.GA25578@rivenstone.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joseph Fannin wrote:
> "Craig A. Huegen" <huegen@pentics.com> wrote:
> 
>>In the same vein as:
>>http://seclists.org/lists/linux-kernel/2003/Oct/5794.html
> 
> 
>>...there is a bug in the SiS900 driver in 2.6.1 which prevents multicast
>>MAC filtering from working properly.  This breaks IPv6.
> 
> 
>     I'm seeing this problem too.  My sis900 interface can't get an
> IPv6 address unless promiscious or allmulti mode is set, since it
> doesn't get responses on ip6-allrouters.
> 
>     Please note that I am not subscribed to netdev, so a CC on any
> responses would be appreciated.
> 
> 
>>Patch attached (same one as from the 2.4 post from Oct 28) that made
>>IPv6 work for me again.
> 
> 
>     From the original post, referring to the change this reverts:
> 
> 
>>>This will not work for bit_nr larger than 16 and hence the failure.
>>>Reverting to use set_bit causes multicast to be handled properly.
> 
> 
>>--- linux/drivers/net/sis900.c.old	2004-01-17 03:56:53.893211412 -0600
>>+++ linux/drivers/net/sis900.c	2004-01-17 03:57:02.785567615 -0600
>>@@ -2091,9 +2091,8 @@
>> 		rx_mode = RFAAB;
>> 		for (i = 0, mclist = net_dev->mc_list; mclist && i < net_dev->mc_count;
>> 		     i++, mclist = mclist->next) {
>>-			unsigned int bit_nr =
>>-				sis900_mcast_bitnr(mclist->dmi_addr, revision);
>>-			mc_filter[bit_nr >> 4] |= (1 << bit_nr);
>>+			set_bit(sis900_mcast_bitnr(mclist->dmi_addr, revision),
>>+				mc_filter);
>> 		}
>> 	}
> 
> 
>     This fix didn't go into 2.4 either, so presumably something is wrong
> with it (perhaps we're moving away from set_bit)?  I am over my head
> here really, but I don't want to just set allmulti mode and forget
> about this bug.


Correct, set_bit should only occur on unsigned long variables.  So, the 
code needs to manually set that bit.

	Jeff
