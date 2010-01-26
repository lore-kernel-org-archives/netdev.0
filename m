From: Michael <michael@moffatt.org.nz>
Subject: Re: [PATCH] starfire: Clean up properly if firmware loading fails
Date: Tue, 26 Jan 2010 15:58:39 +1300
Message-ID: <4B5E5A5F.90608@moffatt.org.nz>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
 <20100125170816.db9435ed.akpm@linux-foundation.org>
 <1264471333.373.349.camel@localhost>
 <20100125181508.790010cb.akpm@linux-foundation.org>
 <1264473168.373.354.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.clear.net.nz ([203.97.37.64]:33024 "EHLO
	smtp4.clear.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab0AZC6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 21:58:45 -0500
Received: from zurvan.moffatt.org.nz
 (203-79-69-250.cable.telstraclear.net [203.79.69.250])
 by smtp4.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0KWU00H2Y2XT9G10@smtp4.clear.net.nz> for
 netdev@vger.kernel.org; Tue, 26 Jan 2010 15:58:44 +1300 (NZDT)
In-reply-to: <1264473168.373.354.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I think I'm the submitter that Ben is referring to.

So that could be the answer to the kernel BUG I have reported, but I 
don't think that it will answer why the interface doesn't come up... or 
does it?

Cheers,
Michael.

Ben Hutchings wrote:
> On Mon, 2010-01-25 at 18:15 -0800, Andrew Morton wrote:
>   
>> On Tue, 26 Jan 2010 02:02:12 +0000 Ben Hutchings <bhutchings@solarflare.com> wrote:
>>
>>     
>>> netdev_open() will return without cleaning up net device or hardware
>>> state if firmware loading fails.  This results in a BUG() on a second
>>> attempt to bring the interface up, reported in
>>> <http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has
>>> even worse effects if the driver is removed afterwards.
>>>       
>> (That's the wrong bugzilla URL)
>>     
>
> Hah, well spotted.  Must have copied from the wrong tab.
>
>   
>>> Call netdev_close() to clean up on failure.
>>>       
>> OK, thanks.
>>
>>     
>>> ---
>>> On Mon, 2010-01-25 at 17:08 -0800, Andrew Morton wrote: 
>>>       
>>>> (switched to email.  Please respond via emailed reply-to-all, not via the
>>>> bugzilla web interface).
>>>>
>>>> On Wed, 20 Jan 2010 04:29:20 GMT
>>>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>>>
>>>>         
>>>>> http://bugzilla.kernel.org/show_bug.cgi?id=15091
>>>>>
>>>>>            Summary: starfire causes kernel BUG when interface goes up
>>>>>           
>>> [...] 
>>>       
>>>>> I formerly used 2.6.20 and 2.6.24 with a couple of starfire 4 port ethernet
>>>>> cards. On 2.6.32 the interfaces don't start on boot and when I issue "ifconfig
>>>>> ethX up" (where X is a starfire port).
>>>>>           
>>> [...] 
>>>       
>>>> Starfire is triggering the BUG_ON(!test_bit(NAPI_STATE_SCHED,
>>>> &n->state)); in napi_enable().
>>>>
>>>> This is a regression somewhere between 2.6.24 and 2.6.32(!).
>>>>         
>>> This driver now attempts to load firmware when an interface is brought
>>> up, *after* calling napi_enable().  If that fails, it will return
>>> without calling napi_disable().  On the second attempt to bring the
>>> interface it calls napi_enable() a second time and triggers this
>>> assertion.
>>>
>>> As a workaround, try installing the necessary firmware. :-)
>>>
>>>       
>> Missing signed-off-by.  I added it, OK?  Also added a Cc:stable.
>>     
> [...]
>
> Well I was going to wait and see what the submitter says first, but I'm
> happy for you to add that in your patch set if it's a positive result.
>
> Ben.
>
>   

