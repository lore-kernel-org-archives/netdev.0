From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] macvlan: Support interface operstate properly
Date: Wed, 6 Apr 2016 23:42:03 +0200
Message-ID: <570582AB.3040702@cumulusnetworks.com>
References: <1459974608-25324-1-git-send-email-dbanerje@akamai.com>
 <570579AA.6050400@cumulusnetworks.com>
 <53A6C2CA-9C49-4F85-97F6-DD60276AFCC2@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "Banerjee, Debabrata" <dbanerje@akamai.com>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38719 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbcDFVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 17:42:12 -0400
Received: by mail-wm0-f48.google.com with SMTP id u206so62783944wme.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 14:42:11 -0700 (PDT)
In-Reply-To: <53A6C2CA-9C49-4F85-97F6-DD60276AFCC2@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2016 11:26 PM, Banerjee, Debabrata wrote:
> On 4/6/16, 5:03 PM, "Nikolay Aleksandrov" <nikolay@cumulusnetworks.com> wrote:
> 
> 
>> On 04/06/2016 10:30 PM, Debabrata Banerjee wrote:
>>> Set appropriate macvlan interface status based on lower device and our
>>> status. Can be up, down, or lowerlayerdown.
>>>
>>> Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
>>>
>>
>> May I ask what is exactly that you're fixing here ? I recently had to make macvlan's
>> operstates more accurate and I haven't experienced any wrong behaviour since commit
>> de7d244d0a35 ("macvlan: make operstate and carrier more accurate").
> 
> Yes I saw the other patch, it's an improvement from when I started working on this. 
> 
> 
>> Also it's the linkwatch's job to take care for the proper operstate, we can use
>> netif_stacked_transfer_operstate to help it, but I don't think directly setting
>> operstate is a good idea.
> 
> This patch was modeled after __hsr_set_operstate(). But I agree there's probably
> better ways to do it. I'm not sure why netif_stacked_transfer_operstate() doesn't do
> it itself, although in the case of a layered device, my patch actually uses the other
> possible state, which is lowerlayerdown. Without the patch operstate goes directly to
> down.
> 
>>
>> One more thing - you cannot use netdev_state_change() under the write_lock as it
>> may sleep.
> 
> You're right, I can resubmit moving the call out of the critical section, if the patch
> will be taken.
> 

I don't know if it'll be taken, but you can submit v2 for review. I'll review and
test it tomorrow as it's late here and I'm tired. :-)
Since this is not a bug fix, I'd suggest to target net-next and you
don't have to CC linux-kernel@vger.kernel.org.

Thanks for the explanation, I misread part of the patch at first and was confused,
but I got the idea now.

Cheers,
 Nik
