From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netlabel: improve domain mapping validation
Date: Sat, 18 May 2013 01:47:15 +0400
Message-ID: <5196A563.70004@cogentembedded.com>
References: <20130517190850.11148.51057.stgit@localhost> <51968397.6010808@cogentembedded.com> <1368823708.cY7J5lAl7C@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	vlad.halilov@gmail.com, selinux@tycho.nsa.gov
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1368823708.cY7J5lAl7C@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2013 11:37 PM, Paul Moore wrote:

>>> The net/netlabel/netlabel_domainhash.c:netlbl_domhsh_add() function
>>> does not properly validate new domain hash entries resulting in
>>> potential problems when an administrator attempts to add an invalid
>>> entry.  One such problem, as reported by Vlad Halilov, is a kernel
>>> BUG (found in netlabel_domainhash.c:netlbl_domhsh_audit_add()) when
>>> adding an IPv6 outbound mapping with a CIPSO configuration.
>>>
>>> This patch corrects this problem by adding the necessary validation
>>> code to netlbl_domhsh_add() via the newly created
>>> netlbl_domhsh_validate() function.
>>>
>>> Ideally this patch should also be pushed to the currently active
>>> -stable trees.
>>>
>>> Reported-by: Vlad Halilov <vlad.halilov@gmail.com>
>>> Signed-off-by: Paul Moore <pmoore@redhat.com>
> ...
>
>>> +#if IS_ENABLED(CONFIG_IPV6)
>>     Why not:
>>
>>           if (IS_ENABLED(CONFIG_IPV6))
>>
>>      #if's in the function body are frowned upon.
> The dependent functions/types are not defined when !IS_ENABLED(CONFIG_IPV6);
> please look at the rest of the NetLabel code (net/netlabel).

     Sorry, didn't think about declarations.

> Perhaps we can do some work to fixup some of that in the future, but that
> shouldn't hold up this fix.

     Perhaps factoring out the #ifdef'ed code into a separate function 
would help
if at all possible.

WBR, Sergei

