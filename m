From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 15:33:34 -0200
Message-ID: <5489D56E.4010505@gmail.com>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com> <20141211170928.62c8e637@griffin> <20141211163335.GA27913@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:58491 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581AbaLKRdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 12:33:40 -0500
Received: by mail-qa0-f41.google.com with SMTP id f12so3980779qad.14
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 09:33:39 -0800 (PST)
In-Reply-To: <20141211163335.GA27913@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-2014 14:33, vadim4j@gmail.com wrote:
> On Thu, Dec 11, 2014 at 05:09:28PM +0100, Jiri Benc wrote:
>> On Thu, 11 Dec 2014 00:56:35 +0200, Vadim Kochan wrote:
>>> From: Vadim Kochan <vadim4j@gmail.com>
>>>
>>> Added new '-ns' option to simplify executing following cmd:
>>>
>>>      ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>>>
>>>      to
>>>
>>>      ip -ns NETNS OPTIONS COMMAND OBJECT
>>>
>>> e.g.:
>>>
>>>      ip -ns vnet0 link add br0 type bridge
>>
>> This is great! It's a thing that has been bothering me for long time
>> but never got high enough on my todo list. Thanks for working on this.
>>
>> However,
>>
>>> --- a/ip/ip.c
>>> +++ b/ip/ip.c
>>> @@ -262,6 +262,12 @@ int main(int argc, char **argv)
>>>   			rcvbuf = size;
>>>   		} else if (matches(opt, "-help") == 0) {
>>>   			usage();
>>> +		} else if (matches(opt, "-ns") == 0) {
>>> +			argc--;
>>> +			argv++;
>>> +			argv[0] = argv[1];
>>> +			argv[1] = basename;
>>> +			return netns_exec(argc, argv);
>>
>> I very much dislike this. There's no reason to exec another ip binary.
>> The main reason I wanted the -n (or whatever) option was to speed up
>> execution of test scripts in environments with hundreds of interfaces
>> in different net namespaces.
>>
>> Please just change to the specified netns and continue with interpreting
>> of the rest of the command line, there's absolutely no reason for doing
>> the exec.
> Yes, I will follow that way.

In that case, it would be interesting to also accelerate the original use 
case, no? So all usages we currently have will benefit from this speed up 
without a change.

if (command to be executed == myself)
   switch namespace, continue without fork/exec..

I'm not sure if this is feasible, though. Just sharing the idea, didn't even 
open the code..

   Marcelo
