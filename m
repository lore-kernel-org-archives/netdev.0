From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/1] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Thu, 3 Dec 2015 14:41:14 +0300
Message-ID: <56602A5A.4020701@cogentembedded.com>
References: <1449060889-20447-1-git-send-email-clabbe.montjoie@gmail.com>
 <1449060889-20447-2-git-send-email-clabbe.montjoie@gmail.com>
 <565EF9EB.3000509@cogentembedded.com> <20151203075257.GA13787@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151203075257.GA13787@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/3/2015 10:52 AM, LABBE Corentin wrote:

>>> The simple_strtol function is obsolete.
>>> This patch replace it by kstrtoint.
>>> This will simplify code, since some error case not handled by
>>> simple_strtol are handled by kstrtoint.
>>>
>>> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
>>> ---
>>>    drivers/atm/solos-pci.c | 28 +++++++++++++++-------------
>>>    1 file changed, 15 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
>>> index 3d7fb65..f944d75 100644
>>> --- a/drivers/atm/solos-pci.c
>>> +++ b/drivers/atm/solos-pci.c
>>> @@ -347,8 +347,8 @@ static char *next_string(struct sk_buff *skb)
>>>     */
>>>    static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
>>>    {
>>> -	char *str, *end, *state_str, *snr, *attn;
>>> -	int ver, rate_up, rate_down;
>>> +	char *str, *state_str, *snr, *attn;
>>> +	int ver, rate_up, rate_down, err;
>>>
>>>    	if (!card->atmdev[port])
>>>    		return -ENODEV;
>>> @@ -357,11 +357,11 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
>>>    	if (!str)
>>>    		return -EIO;
>>>
>>> -	ver = simple_strtol(str, NULL, 10);
>>> -	if (ver < 1) {
>>> +	err = kstrtoint(str, 10, &ver);
>>> +	if (ver < 1 || err) {
>>
>>      Is 'ver' initialized in case of error? If not, you have to check 'err' first.
>
> Hello
>
> Whatever if ver is initialized,

    I meant initialized by kstrtoint().

> since the conditional is an or, the test will always be true with the err value.

    I don't understand you. If you test 'ver' first, you risk testing 
uninitialized variable.

> Anyway I will send an updated version.

    Let's see...

> Regards

MBR, Sergei
