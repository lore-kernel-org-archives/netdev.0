From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: Interface proposal for rx classification using ethtool
Date: Fri, 31 Oct 2008 05:29:07 -0500
Message-ID: <75E689AC-0AA6-4AB2-A7D9-0B16EDB5AF28@kernel.crashing.org>
References: <48E11027.3060400@Sun.COM>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36345 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYJaK3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 06:29:18 -0400
In-Reply-To: <48E11027.3060400@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 29, 2008, at 12:28 PM, Santwona.Behera@Sun.COM wrote:

> Here is the proposed design for implementing an interface to add,  
> delete and
> manage rules for RX packet classification on ethertool with niu as  
> the first
> target hardware. This is the second installment of network flow  
> classification
> support (the first one was for rx flow distribution based on hashing  
> that was
> added in June). Please review and send your feedback.
>
> 1. The ethertool application will have an interface to add a  
> classification rule
> and the target RX ring for packets that match the rule. The rules  
> are added
> on a per port basis. Each new rule that is added is represented by a  
> unique ID.
> This ID can be used by the user to delete the rule or query the  
> details of the
> rule (both interfaces provided via ethertool).
>
> 2. Here is the list of cmds/interfaces that will be added to  
> ethertool (as
> suboptions in the rx_classification option) to achieve this:
>
>  - get the number of RX rings available to this port.
>  - add a rule (flow-tuple/mask to RX ring mapping)
>  - delete a rule
>  - query a particular rule or all rules for this port
>
> 3. Within ethertool, there will be a manager for these rules that  
> will order
> the rules on a per port basis according to the policy chosen by the  
> user. In
> the first cut, the policy will be hardcoded as longest prefix first  
> ordering.
> Before adding any rules to the hardware, the rule manager will first  
> query
> the hardware for the ordering that it implements for matching, e.g.,  
> low-to-high
> (as in case of niu TCAM). This information will be taken into  
> account while
> writing to the rule-manager and to the hardware.
>
> 4. In the niu driver, there will be a local array of the  
> tcam_entries (for
> supporting queries from ethertool).
>
> 5. There is no protection against inconsistencies between the tcam  
> entries
> and the user view of it that can arise if multiple instances of  
> ethertool
> happen to write the same rule (tcam_entry).

What's the state of patches for this work?

- k
