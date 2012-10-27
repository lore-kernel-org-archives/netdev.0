From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new SCTP_GET_ASSOC_STATS call
Date: Sat, 27 Oct 2012 11:50:50 -0400
Message-ID: <C2B32932-B137-44DD-9E4D-821EBDE08179@gmail.com>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org> <20121026143704.GC25087@hmsreliant.think-freely.org> <20121027113541.GA7966@marquez.int.rhx> <DB10D819-2751-4467-858A-C4ED1DBED9F4@gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Michele Baldessari <michele@acksyn.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:62975 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759214Ab2J0Pux convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 11:50:53 -0400
In-Reply-To: <DB10D819-2751-4467-858A-C4ED1DBED9F4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct 27, 2012, at 11:48 AM, Vlad Yasevich <vyasevich@gmail.com> wrote:

> 
> 
> 
> 
> On Oct 27, 2012, at 7:35 AM, Michele Baldessari <michele@acksyn.org> wrote:
> 
>> Hi Neil & Vlad,
>> 
>> On Fri, Oct 26, 2012 at 10:37:04AM -0400, Neil Horman wrote:
>>> We already have files in /proc/net/sctp to count snmp system-wide totals,
>>> per-endpoint totals, and per association totals.  Why do these stats differently
>>> instead of just adding them the per-association file?  I get that solaris does
>>> this, but its not codified in any of the RFC's or other standards.  I would
>>> really rather see something like this go into the interfaces we have, rather
>>> than creating a new one.
>>> 
>>> I also am a bit confused regarding the stats themselves.  Most are fairly clear,
>>> but some seem lacking (you count most things sent and received, but only count
>>> received gap acks).  Others seems vague and or confusing (when counting
>>> retransmitted chunks and packets, how do you count a packet that has both new
>>> and retransmitted chunks)?  And the max observed rto stat is just odd.  Each
>>> transport has an rto value, not each association, and you cal already see the
>>> individual transport rto values in /proc/net/sctp/remaddr.
>> 
>> thanks a lot for your time reviewing this. I will try to address all
>> your comments in a second version of the patch. One thing I am not too
>> sure though: do you prefer me extending /proc/net/sctp/* or implement a
>> new call.
>> 
>> I ask because from a previous private communication with Vlad the new
>> socket option seemed to be the preferred approach.
>> I am fine either way just let me know ;)
> 
> 
> socket option is preferable as /proc doesn't scale very well as number of associations grows.

One thing of note that I didn't think of before is that you want his option to be in the lksctp private space, not the API spec space.


> 
> -Vlad
> 
>> 
>> cheers,
>> -- 
>> Michele Baldessari            <michele@acksyn.org>
>> C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
