From: Joe Harvell <joe.harvell@tekcomms.com>
Subject: Re: [PATCH] iproute2: enhance addr label validation
Date: Mon, 23 Mar 2015 09:02:47 -0500
Message-ID: <55101D07.6090301@tekcomms.com>
References: <550DD13D.90009@tekcomms.com>
 <20150323011522.GB20755@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Stephen Hemminger <shemming@brocade.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0134.outbound.protection.outlook.com ([157.56.110.134]:53792
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751873AbbCWOEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 10:04:20 -0400
In-Reply-To: <20150323011522.GB20755@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Hi Joe,
>
> On Sat, Mar 21, 2015 at 03:14:53PM -0500, Joe Harvell wrote:
>> The ip addr command today rejects address labels that would break
>> ifconfig.  However, it allows some labels which still break it. Enhance
>> enforcement to reject all known incompatible labels, and allow the
>> existing -force option to allow someone to use a label even if it is not
>> ifconfig compatible
> I am concerned this will break existing users who are relying on setting
> labels that would now be rejected without using -force.
>
[snip]

Simon,

Good point.  I propose the following:

When a label is specified without -force, and that label begins with the 
interface
name but is followed by something other than a colon, accept the label 
but emit
a warning message indicating this label is incompatible with ifconfig 
and that later
versions of the 'ip address' command may reject it.  This message can 
also indicate
that -force can be specified to explicitly indicate a label that is non 
ifconfig compatible
is desired.

At some point in the future, the behavior could then be changed to 
reject such labels.

What do you think?

---
Joe
