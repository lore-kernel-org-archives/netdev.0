From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 v4] ipbatch: fix use of 'ip netns exec'
Date: Tue, 09 Jul 2013 18:59:43 +0200
Message-ID: <51DC417F.5080708@6wind.com>
References: <1373376013.4979.148.camel@edumazet-glaptop>  <1373385312-4899-1-git-send-email-nicolas.dichtel@6wind.com> <1373386764.2523.1.camel@bwh-desktop.uk.level5networks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, junwei.zhang@6wind.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:48990 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898Ab3GIQ7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 12:59:48 -0400
Received: by mail-wg0-f50.google.com with SMTP id k14so5057595wgh.29
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 09:59:46 -0700 (PDT)
In-Reply-To: <1373386764.2523.1.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/07/2013 18:19, Ben Hutchings a =C3=A9crit :
> On Tue, 2013-07-09 at 17:55 +0200, Nicolas Dichtel wrote:
> [...]
>> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
>> index fa2b681..cdc3101 100644
>> --- a/ip/ipnetns.c
>> +++ b/ip/ipnetns.c
>> @@ -42,6 +42,7 @@
>>   #define MS_SHARED	(1 << 20)
>>   #endif
>>
>> +extern char *batch_file;
I let Stephen choose, he suggest me this.

>
> Should be declared in a header file.
>
>>   #ifndef HAVE_SETNS
>>   static int setns(int fd, int nstype)
>> @@ -185,6 +186,42 @@ static int netns_exec(int argc, char **argv)
>>   	/* Setup bind mounts for config files in /etc */
>>   	bind_etc(name);
>>
>> +	if (batch_file) {
>> +		int status;
>> +		pid_t pid;
>> +
>> +		pid =3D fork();
>> +		if (pid < 0) {
>> +			perror("fork");
>> +			return EXIT_FAILURE;
>
> return -1;
man exit says:
The use of EXIT_SUCCESS and EXIT_FAILURE is slightly more portable (to =
non-UNIX=20
environments) than the use of 0 and some nonzero value like 1 or -1.

And in fact, it was so before my patch.
