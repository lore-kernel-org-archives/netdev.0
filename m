From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 18:48:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE492E.9080308@pobox.com>
References: <3EEE28DE.6040808@us.ibm.com> <20030616.133841.35533284.davem@redhat.com> <3EEE2F9F.60706@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, Daniel Stekloff <stekloff@us.ibm.com>,
   Janice Girouard <girouard@us.ibm.com>, Larry Kessler <lkessler@us.ibm.com>,
   kenistonj@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Janice M Girouard <janiceg@us.ibm.com>
In-Reply-To: <3EEE2F9F.60706@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Janice M Girouard wrote:
> I agree that it's not desirable to introduce a bunch of messages that we 
> aren't already logging.  I didn't show the netif_msg prefix because I 
> was trying to focus the patch on the common messages, but you would 
> normally proceed a message with:
> 
> if netif_msg_link()
>   printk("some text to indicate the link is up/down")
> 
> The netif_msg_link test would normally filter out what messages should 
> be logged.


There are several issues at play here.

1) In general, I think you're approaching the logging from the wrong 
angle.  Start with netif_msg_xxx/NETIF_MSG_xxx first, and figure out the 
logging API for those cases.  These cover the majority of common cases, 
and most are not specific to hardware at all.  Starting at the driver 
level and trying to move driver-specific messages into the upper layers 
is the wrong direction, I feel.

2) If we are going to do major surgery on messages, make them more 
computer-parseable at the same time.  Human readable, since it must 
above-all-else be kernel hacker readable, ... but computer parseable.

Here is an example.  DISCLAIMER:  No doubt there is a better format, it 
is merely for illustration.
	"%s: performance event: scatter/gather I/O disabled\n"
		becomes
	"dev=%s evt=perf sgio=disabled\n"

Basically a key-value format.  Resist the urge to use numeric response 
codes.  For stuff like this, I think both Linus and the typical human 
brain prefer English words to numeric response codes.  This suggested 
output is not unlike some arch's show-processor-state sysrq output.

3) _Somebody_ needs to do some "ground pounding", and figure out what 
info sysadmins and users want to see.  Event logging in general, so far, 
seems to me more like a management checklist item than a real user 
need... but I am quite willing to be proved wrong.  Until we get 
feedback along these lines, I tend to resist changes like this in 
general.  My initial read of your attached patch was that it was a long 
of source churn, and I couldn't fathom what any user would gain from it all.

	Jeff



There are a whole bunch of netif_msg_xxx and corresponding NETIF_MSG_xxx 
bits.  I don't see much need to change that I think getting the logging 
API right for those would be an important first step.

	Jeff


P.S. It is important to note the bits are laid out in increasing verbosity.
