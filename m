From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: [PATCH]net:8021q:vlan.c Fix pr_info to read on line in the syslog.
Date: Mon, 23 May 2011 21:33:28 -0700
Message-ID: <4DDB3518.4040808@gmail.com>
References: <1306166698-2036-1-git-send-email-justinmattock@gmail.com> <1306167781.8687.20.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306167781.8687.20.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2011 09:23 AM, Joe Perches wrote:
> On Mon, 2011-05-23 at 09:04 -0700, Justin P. Mattock wrote:
>> The patch below changes the pr_info so that it reads on one line in the syslog
>> rather than two.
>>
>> before:
>>
>> [   30.438203] 802.1Q VLAN Support v1.8 Ben Greear<greearb@candelatech.com>
>> [   30.441542] All bugs added by David S. Miller<davem@redhat.com>
>>
>>
>> after:
>> [   29.356282] 802.1Q VLAN Support v1.8 Ben Greear<greearb@candelatech.com>  All bugs added by: David S. Miller<davem@redhat.com>
>>
>> Signed-off-by: Justin P. Mattock<justinmattock@gmail.com>
>>
>> ---
>>   net/8021q/vlan.c |    4 ++--
>>   1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index b2274d1..02f4d8b 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -673,8 +673,8 @@ static int __init vlan_proto_init(void)
>>   {
>>   	int err;
>>
>> -	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
>> -	pr_info("All bugs added by %s\n", vlan_buggyright);
>> +	pr_info("%s v%s %s All bugs added by: %s\n", vlan_fullname, vlan_version,
>> +		vlan_copyright, vlan_buggyright);
>
> Might as well avoid the format string then too.
>
> 	pr_info(vlan_fullname " v" vlan_version " " vlan_copyright
> 		" All bugs added by: " vlan_buggyright "\n");
>
> or just kill the otherwise unused vlan_<foo>  variables
>
> 	pr_info("802.1Q VLAN Support v" vlan_version
> 		" Ben Greear<greearb@candelatech.com>"
> 		" All bugs added by: David S. Miller<davem@redhat.com>\n");
>
> though I think that emitting names on startup isn't necessary and
> this is enough:
>
> 	pr_info("802.1Q VLAN Support v" vlan_version "\n");
>
>
>

alright, I will resend this with what you have then.

Justin P. Mattock
