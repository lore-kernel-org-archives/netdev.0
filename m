From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Wed, 18 May 2016 22:05:55 -0600
Message-ID: <7b91db2e-9e27-48e3-e080-00037bc1a9c3@cumulusnetworks.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
 <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
 <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
 <3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
 <CAKD1Yr0E9i0s0ocSyYhEjODnVVQVBPOfbepvORAhT9gi9Qqz6A@mail.gmail.com>
 <a3cafb2342fa6a754fc389947f77f248@codeaurora.org>
 <CAKD1Yr1u-p8hyjd_e672kYrXw+-Mkmj_Cxai=WUYM-9QQG=DQg@mail.gmail.com>
 <4ca62c9f-4d19-4dd1-0d8c-c2cfe17c0443@cumulusnetworks.com>
 <1463629667.18194.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35683 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbcESEF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 00:05:59 -0400
Received: by mail-io0-f179.google.com with SMTP id p64so413148ioi.2
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 21:05:59 -0700 (PDT)
In-Reply-To: <1463629667.18194.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/16 9:47 PM, Eric Dumazet wrote:
> On Wed, 2016-05-18 at 21:02 -0600, David Ahern wrote:
>> On 5/18/16 6:55 PM, Lorenzo Colitti wrote:
>>> On Wed, May 18, 2016 at 3:35 AM, <subashab@codeaurora.org> wrote:
>>>> Would it be acceptable to have a separate column which displays the result of the sock destroy operation per socket.
>>>> State    ... Killed
>>>> ESTAB         Y
>>>> TIME_WAIT     N
>>>
>>> Fine by me, but... what problem are we trying to address? People who
>>> compile their own kernels and don't turn CONFIG_INET_DIAG_DESTROY, and
>>> then are confused why it doesn't work? Seems like we could fix that by
>>> turning CONFIG_INET_DIAG_DESTROY on by default. CCing the people who
>>> commented on the original SOCK_DESTROY patch to see if they have
>>> opinions.
>>
>> The problem is proper feedback to a user. If the kernel supports an
>> action but the action is not enabled the user should get some message to
>> that fact. Doing nothing and exiting 0 is just wrong.
>
> So, lets say the filter found 123456 sockets matching the filter, and
> 12345 could be killed
>
> What would be exit status of ss command ?

Again, I could care less if the exit status is 0 if the user is given "A 
request failed b/c operations is not supported" message. That is feedback.

>
> In this case, there is no black/white answer.
>
> It looks like you have specific needs, you should probably add an option
> to ss to have a specific behavior.
>
> But saying current behavior is 'wrong' is subjective.

You think it is ok to send a request to the kernel, the kernel says "I 
can't do it" and the command says nothing to the user? That is current 
behavior. How on Earth is that acceptable?

I believe my last proposal is that that user gets a single "I could not 
do what you asked" message and nice little summary:

N sockets closed
M sockets failed

If M = total number of sockets then perhaps there is a bigger problem -- 
like a config option is not enabled.
