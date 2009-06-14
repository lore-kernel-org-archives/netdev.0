From: Eric Lammerts <eric@lammerts.org>
Subject: Re: 2.6.30: tun losing ip
Date: Sun, 14 Jun 2009 14:36:10 -0400
Message-ID: <4A35431A.50507@lammerts.org>
References: <4A348824.1030503@lammerts.org> <Pine.LNX.4.64.0906141015130.11221@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, gregkh@suse.de,
	netdev@vger.kernel.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762662AbZFNSgb@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0906141015130.11221@sister.anvils>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2009 05:28 AM, Hugh Dickins wrote:
> On Sun, 14 Jun 2009, Eric Lammerts wrote:
>> There is something strange going on with tun devices:
<snip>
>> First you see the ip, then you don't...
>>
>> I traced it back to this commit:
>>
>> $ git-bisect bad
>> 05f54c13cd0c33694eec39a265475c5d6cf223cf is first bad commit
>> commit 05f54c13cd0c33694eec39a265475c5d6cf223cf
>> Author: Hugh Dickins <hugh@veritas.com>
>> Date:   Thu Apr 16 21:55:29 2009 +0100
>>
>>     Revert "kobject: don't block for each kobject_uevent".
>>
>> If I take 2.6.30 and revert that commit, the problem goes away.
> 
> I'm mortified!  But it's rather odd, that's just a straight reversion
> of an earlier, clearly buggy commit: I guess you have some other issue,
> which reverting to a wait here now uncovers.
> 
> One likely workaround: I suspect your .config says something like
> CONFIG_UEVENT_HELPER_PATH=/sbin/hotplug, but you've no /sbin/hotplug?
> Please try changing that to CONFIG_UEVENT_HELPER_PATH="", and see if
> the problem comes up with that resulting kernel.

Actually I do have an /sbin/hotplug, with I now noticed has some old 
script stuff behind it that starts a udhcpc... aarrrgh. I removed it and 
the problem's gone.

Apologies for wasting your time.

Eric
