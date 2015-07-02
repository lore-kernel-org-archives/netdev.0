From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] rtnetlink: Actually use the policy for the IFLA_VF_INFO
Date: Thu, 02 Jul 2015 10:34:54 +0200
Message-ID: <5594F7AE.3010704@iogearbox.net>
References: <20150630225255.GA22529@obsidianresearch.com> <5593B48F.2060403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60371 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbbGBIfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 04:35:03 -0400
In-Reply-To: <5593B48F.2060403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2015 11:36 AM, Daniel Borkmann wrote:
> Hi Jason,
>
> On 07/01/2015 12:52 AM, Jason Gunthorpe wrote:
>> It turns out the policy was defined but never actually checked,
>> so lets check it.
>>
>> Fixes: ebc08a6f47ee ("rtnetlink: Add VF config code to rtnetlink")
>
> I would argue that the actual commit would be ...
>
> Fixes: c02db8c6290b ("rtnetlink: make SR-IOV VF interface symmetric")
>
> ... since in ebc08a6f47ee, these members were part of ifla_policy[]
> which has been validated (if we ignore the fact that it was NLA_BINARY).
>
> So, commit c02db8c6290b moved it into a nested attribute (IFLA_VF_INFO)
> where we indeed don't do further validation. Imho, we should pass the
> parsed attribute table from nla_parse_nested() down into do_setvfinfo(),
> something like the below; I can give it a test run on my ixgbe.

Sorry for the late reply, something like this looks good from my side.

Thanks,
Daniel
