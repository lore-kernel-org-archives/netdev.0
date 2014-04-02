From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 2 Apr 2014 08:51:51 +0300
Message-ID: <CAF1J0HOyAaAnMU+Eb-SLdy8CzmOiueSr7K-cc6TbfCf5hm_66A@mail.gmail.com>
References: <1396333381-7252-1-git-send-email-mike.rapoport@ravellosystems.com>
	<CAHA+R7OO9Cc-vVzeQ4dozj1HyBgU9pHZL-aJL9KxYKx+SVaLVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7OO9Cc-vVzeQ4dozj1HyBgU9pHZL-aJL9KxYKx+SVaLVA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 1, 2014 at 10:22 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Mon, Mar 31, 2014 at 11:23 PM, Mike Rapoport
> <mike.rapoport@ravellosystems.com> wrote:
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 1236812..d091e52 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -871,6 +871,9 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>>         if (err)
>>                 return err;
>>
>> +       if (vxlan->default_dst.remote_ip.sa.sa_family != ip.sa.sa_family)
>> +               return -EAFNOSUPPORT;
>> +
>
> Or move this check into vxlan_fdb_parse() so that vxlan_fdb_delete()
> could also catch this error?

The vxlan_fdb_delete will fail to find an entry with address from
incompatible family, and will return -ENOENT.

-- 
Sincerely yours,
Mike.
