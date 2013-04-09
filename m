From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/3 net-next RFC] selftest: add abstractions for net selftests
Date: Tue, 09 Apr 2013 13:32:07 +0200
Message-ID: <5163FC37.4090202@redhat.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com> <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com> <5163F7E1.8040208@redhat.com> <CAHG7+CBWF-gLcNfvnP2NQjkAwgtv+k6=0DndN1Mu2b+1acHj-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com,
	edumazet@google.com, Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935236Ab3DILch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:32:37 -0400
In-Reply-To: <CAHG7+CBWF-gLcNfvnP2NQjkAwgtv+k6=0DndN1Mu2b+1acHj-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 01:24 PM, Alexandru Copot wrote:
> On Tue, Apr 9, 2013 at 2:13 PM, Daniel Borkmann <dborkman@redhat.com> wrote:

>>> +#define CHECK(cond,fmt,...)                            \
>>> +       do {                                            \
>>> +               if (!(cond)) {                          \
>>> +                       fprintf(stderr, "(%s, %d): " fmt,       \
>>> +                                       __FILE__, __LINE__,
>>> ##__VA_ARGS__); \
>>> +                       perror("");                     \
>>> +                       return 1;                       \
>>> +               }                                       \
>>> +       } while (0)
>>
>>
>> Isn't it a bit error-prone if in the middle of somewhere this check fails
>> and the function suddenly returns 1?
>>
>> What if this is called from a function that was declared as void or to
>> return a pointer to a struct etc.?
>
> Well, I tought of using this only in your high-level testcase methods
> (test->run()).
> It is also easier to see what is actually being tested.
>
> For anything else the user is free to use any other functions or
> return conventions
> as the test requires.

Hm, then, still not convinced about the CHECK macro. In worst case this at
least needs a comment, so that people will not misuse that, but with your
two statements above, it seems likely that people could also start using it
in "any other functions or return conventions as the test requires". ;-)
