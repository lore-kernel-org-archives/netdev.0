From: Paul Collins <paul-uANAyHgy5MnD+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest devscape
	git pull..
Date: Tue, 05 Dec 2006 07:28:40 +1300
Message-ID: <87r6vfh5wn.fsf@briny.internal.ondioline.org>
References: <45733FBF.5020800@gmail.com>
	<87y7pogj1k.fsf@briny.internal.ondioline.org>
	<1165237252.2738.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Robert Martin <robertm83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <1165237252.2738.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Dan Williams's
	message of "Mon\, 04 Dec 2006 08\:00\:52 -0500")
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Mon, 2006-12-04 at 21:30 +1300, Paul Collins wrote:
>> Robert Martin <robertm83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> 
>> > I seem to be having a problem associating with my AP--everything
>> > appears fine and I can bring my wireless adapter up (the LED lights up
>> > correctly), and I don't see complaints about firmware/IRQs in the
>> > dmesg output.  I am able to see operating APs with an "iwlist wlan0
>> > scan", but I am unable to connect to the AP, with or without WEP
>> > encryption enabled (tried none, hex and ascii; nothing worked).  This
>> > is with the latest wireless-dev pull and a vanilla 2.6.19 kernel with
>> > "irqpoll" option enabled, otherwise it misbehaves.  I would be happy
>> > to give more information if requested, or try different
>> > kernel/firmware options.
>> 
>> I started playing with wireless-dev's bcm43xx-d80211 recently and
>> noticed that I had to set the frequency manually.  When I did that,
>> setting the ap manually caused the card to associate immediately.
>
> That sounds suspiciously like the driver either doesn't have the correct
> scan results to be able to pick the AP's frequency, or is not correctly
> searching those scan results to find it...  If the AP is in the scan
> list, the driver should definitely be able to find & set the frequency
> for the AP, _unless_ you've previously specified a non-zero frequency
> for iwconfig ethX freq [1].  Do you see your AP in the 'iwlist wlan0
> scan' output?

Yes, this is how I noticed that iwconfig was reporting a different
frequency to that listed in iwlist scan.

>> Here's the sequence of commands I run.  (The driver seems stable on my
>> hardware, so I've only had to do this twice in the last week, and then
>> only for reasons unrelated to the driver.)
>> 
>>  ip link set up wlan0
>>  iwlist wlan0 scan
>>  iwconfig wlan0 essid $essid key $wep_key
>>  iwconfig wlan0
>> (note frequencies differ)
>>  iwconfig wlan0 freq $freq_from_iwlist_scan
>>  iwconfig wlan0 ap $ap_mac_address
>>  dhclient wlan0

-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood
