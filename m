From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 2/2] iproute2: bridge vlan show new option
 to print ranges
Date: Mon, 26 Jan 2015 10:57:25 -0800
Message-ID: <54C68E15.9060002@cumulusnetworks.com>
References: <1422239185-14054-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCR6YSK9J+OV+04w_UXWoSu56xSvHXkYkDzqP4Qudn76Q@mail.gmail.com> <54C5CE0A.2050209@cumulusnetworks.com> <CAE4R7bAOwQnoC4sbNzW=Tadrp239Lq1f4LwhLR-xeiZg3JdofQ@mail.gmail.com> <54C5DA02.30502@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35701 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938AbbAZS51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 13:57:27 -0500
Received: by mail-pd0-f172.google.com with SMTP id v10so13538319pde.3
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 10:57:27 -0800 (PST)
In-Reply-To: <54C5DA02.30502@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/25/15, 10:09 PM, roopa wrote:
> On 1/25/15, 9:57 PM, Scott Feldman wrote:
>> On Sun, Jan 25, 2015 at 9:18 PM, roopa <roopa@cumulusnetworks.com> 
>> wrote:
>>> On 1/25/15, 8:35 PM, Scott Feldman wrote:
>>>>> diff --git a/bridge/bridge.c b/bridge/bridge.c
>>>>> index 5fcc552..88469ca 100644
>>>>> --- a/bridge/bridge.c
>>>>> +++ b/bridge/bridge.c
>>>>> @@ -21,6 +21,7 @@ int resolve_hosts;
>>>>>    int oneline = 0;
>>>>>    int show_stats;
>>>>>    int show_details;
>>>>> +int compress_vlans;
>>>>>    int timestamp;
>>>>>    char * _SL_ = NULL;
>>>>>
>>>>> @@ -32,7 +33,8 @@ static void usage(void)
>>>>>    "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
>>>>>    "where  OBJECT := { link | fdb | mdb | vlan | monitor }\n"
>>>>>    "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
>>>>> -"                    -o[neline] | -t[imestamp] | -n[etns] name 
>>>>> }\n");
>>>>> +"                    -o[neline] | -t[imestamp] | -n[etns] name |\n"
>>>>> +"                    -c[ompressvlans] }\n");
>>>> This option is awkward at this level since it's specific to bridge 
>>>> vlan
>>>> cmd.
>>>>
>>>> Is it even necessary?  The real user of compressed vlans isn't the
>>>> "bridge show" cmd; just keep "bridge show" simple, listing each vlan
>>>> per line.
>>> without ranges it does get a bit difficult (or rather long) to read 
>>> if there
>>> are many vlans (it was also a comment I received on v2).
>>>
>>> All the available options whether they apply to the immediate 
>>> sub-command or
>>> not are at the toplevel command today.
>>> Hence the position (Not a big fan of the current name. suggestions 
>>> welcome).
>>>
>>> I would have loved to have the default output print ranges, If that is
>>> acceptable. But, that can break new iproute2 on older kernels (If 
>>> that is
>>> something we should care about).
>>>
>>> other option is keyword argument like maybe 'bridge vlan show 
>>> compressed' or
>>> 'bridge vlan show ranges'
>> How about try RTEXT_FILTER_BRVLAN_COMPRESSED first, and if that fails,
>> try RTEXT_FILTER_BRVLAN, and don't add -c option?
>>
>>
> That would have been nice, except that  it will not fail. It will pass 
> but not return any vlans.
>
> Better would be to send both flags. I think that will work. New kernel 
> looks at RTEXT_FILTER_BRVLAN_COMPRESSED first.
> v4  soon ....after some testing ...  ;)
This still means i will end up changing the default/current output into 
vlan ranges on newer kernels. If that is acceptable then i will resubmit 
with v4.
If not, v3 looks ok to me so far.

thanks,
Roopa
