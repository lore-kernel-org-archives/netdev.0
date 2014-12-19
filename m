From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH Iproute2 next] ip netns: 'ip netns id' cmd without
 argument should not give error
Date: Fri, 19 Dec 2014 10:33:15 -0800
Message-ID: <CAF2d9jh=FfT3WtBw_GNpLmN83UscgdU7hBfvF4QtMQq21mMDew@mail.gmail.com>
References: <1418969138-26199-1-git-send-email-maheshb@google.com> <20141219083153.GA11360@angus-think>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Saied Kazemi <saied@google.com>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:55532 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaLSSdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 13:33:36 -0500
Received: by mail-ob0-f172.google.com with SMTP id va8so13753856obc.3
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 10:33:35 -0800 (PST)
In-Reply-To: <20141219083153.GA11360@angus-think>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2014 at 12:31 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> On Thu, Dec 18, 2014 at 10:05:38PM -0800, Mahesh Bandewar wrote:
>> The command 'ip netns identify' without PID parameter is supposed to
>> use the self PID to identify its ns but a trivial error prevented it
>> from doing so. This patch fixes that error.
>>
>> So before the patch -
>>       # ip netns id
>>       No pid specified
>>       # echo $?
>>       1
>>       #
>>
>> After the patch -
>>       # ip netns id
>>       test-ns
>>       # echo $?
>>       0
>>       #
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: Vadim Kochan <vadim4j@gmail.com>
>> Cc: Saied Kazemi <saied@google.com>
>> ---
>>  ip/ipnetns.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
>> index 1c8aa029073e..ec9afa2177a5 100644
>> --- a/ip/ipnetns.c
>> +++ b/ip/ipnetns.c
>> @@ -298,7 +298,7 @@ static int netns_identify(int argc, char **argv)
>>       DIR *dir;
>>       struct dirent *entry;
>>
>> -     if (argc < 1) {
>> +     if (!argc) {
>>               pidstr = "self";
>>       } else if (argc > 1) {
>>               fprintf(stderr, "extra arguments specified\n");
>> --
>> 2.2.0.rc0.207.ga3a616c
>>
>
> Hi Mahesh,
>
> I did not get such error on the current master branch?
>
> Did I miss something ?
>
No you did not! Please ignore this patch. :)

Looks like the tree I was working / using wasn't next and did not have
the patch that made it work (in next). I cherry-picked my fix onto the
next and sent it. My bad!

> Regards,
> Vadim Kochan
