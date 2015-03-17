From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 2/2] tc class: Ignore if default class name file
 does not exist
Date: Tue, 17 Mar 2015 19:37:15 +0100
Message-ID: <5508745B.3060007@iogearbox.net>
References: <1426611124-2295-1-git-send-email-vadim4j@gmail.com> <1426611124-2295-3-git-send-email-vadim4j@gmail.com> <5508658E.9050909@iogearbox.net> <20150317182137.GA1056@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44745 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbbCQShT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:37:19 -0400
In-Reply-To: <20150317182137.GA1056@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2015 07:21 PM, Vadim Kochan wrote:
> On Tue, Mar 17, 2015 at 06:34:06PM +0100, Daniel Borkmann wrote:
>> On 03/17/2015 05:52 PM, Vadim Kochan wrote:
>> ...
>>> Changed default class name file cls_names -> tc_cls.
>>
>> Why that?
>
> tc_cls seems better and shorter.
>
>>> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>>> ---
>>>   tc/tc_util.c | 19 +++++++++++++++----
>>>   1 file changed, 15 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/tc/tc_util.c b/tc/tc_util.c
>>> index feae439..5213e9e 100644
>>> --- a/tc/tc_util.c
>>> +++ b/tc/tc_util.c
>> ...
>>>   static struct db_names *cls_names = NULL;
>>>
>>> -#define NAMES_DB "/etc/iproute2/cls_names"
>>> +#define NAMES_DB "/etc/iproute2/tc_cls"
>>>
>>>   int cls_names_init(char *path)
>>>   {
>>> -	cls_names = db_names_alloc(path ?: NAMES_DB);
>>> -	if (!cls_names) {
>>> -		fprintf(stderr, "Error while opening class names file\n");
>>> +	int ret = -1;
>>> +
>>> +	cls_names = db_names_alloc();
>>> +	if (!cls_names)
>>> +		return -1;
>>> +
>>> +	ret = db_names_load(cls_names, path ?: NAMES_DB);
>>> +	if (ret == -ENOENT && path) {
>>> +		fprintf(stderr, "Can't open class names file: %s\n", path);
>>
>> That would mean that existing users having a /etc/iproute2/cls_names
>> file would suddenly not see class names anymore?
>
> Hm, but that was added few days ago.

Ok, my bad, sorry for the noise.
