From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: Re: [PATCH 1/3 net-next RFC] selftest: add abstractions for net selftests
Date: Tue, 9 Apr 2013 14:24:58 +0300
Message-ID: <CAHG7+CBWF-gLcNfvnP2NQjkAwgtv+k6=0DndN1Mu2b+1acHj-w@mail.gmail.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
	<1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com>
	<5163F7E1.8040208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com,
	edumazet@google.com, Daniel Baluta <dbaluta@ixiacom.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f46.google.com ([209.85.128.46]:48759 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932926Ab3DILY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 07:24:59 -0400
Received: by mail-qe0-f46.google.com with SMTP id nd7so1571935qeb.19
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 04:24:58 -0700 (PDT)
In-Reply-To: <5163F7E1.8040208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 9, 2013 at 2:13 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> +       for (i = 0; i < test->testcase_count; i++) {
>> +               rc = test->run(ptr);
>> +               allrc |= rc;
>> +
>> +               if (test->abort_on_fail && rc) {
>> +                       printf("Testcase %d failed, aborting\n", i);
>> +               }
>
>
> I think here you wanted to abort but didn't?

Yes, I forgot to break;

>> +#define CHECK(cond,fmt,...)                            \
>> +       do {                                            \
>> +               if (!(cond)) {                          \
>> +                       fprintf(stderr, "(%s, %d): " fmt,       \
>> +                                       __FILE__, __LINE__,
>> ##__VA_ARGS__); \
>> +                       perror("");                     \
>> +                       return 1;                       \
>> +               }                                       \
>> +       } while (0)
>
>
> Isn't it a bit error-prone if in the middle of somewhere this check fails
> and the function suddenly returns 1?
>
> What if this is called from a function that was declared as void or to
> return a pointer to a struct etc.?

Well, I tought of using this only in your high-level testcase methods
(test->run()).
It is also easier to see what is actually being tested.

For anything else the user is free to use any other functions or
return conventions
as the test requires.
