From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] geneve: remove use of internal IP header when calling IP_ECN_decapsulate
Date: Fri, 18 Sep 2015 14:49:30 -0700
Message-ID: <CAEP_g=_aDApp8+Uj8JOpg=jzxEs73XzSufgWzA-ODpfXS-ss-Q@mail.gmail.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
 <1442522094-876-1-git-send-email-linville@tuxdriver.com> <CAEP_g=-EGH-hfCRYQ8WStY2btq=1g-y=g=PvC_e-aC8QZKugJA@mail.gmail.com>
 <20150918204023.GD18191@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:36155 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463AbbIRVtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 17:49:53 -0400
Received: by lbcao8 with SMTP id ao8so31252037lbc.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 14:49:49 -0700 (PDT)
In-Reply-To: <20150918204023.GD18191@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 1:40 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Fri, Sep 18, 2015 at 01:30:36PM -0700, Jesse Gross wrote:
>> On Thu, Sep 17, 2015 at 1:34 PM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>> > This seems to have been a "thinko".  IP_ECN_decapsulate needs info
>> > from both internal and external headers.
>> >
>> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
>>
>> This looks good to me although I realized that the transmit path is
>> also conditional based on !collect_md metadata. I suppose that means
>> that this difference is intentional and I guess I could see arguments
>> either way but I still think it is better to be consistent across
>> different code paths in this respect.
>
> I'm happy with the v2 patch if you are. :-)

I'm happy with this part of the code path after this patch. However,
my concern was that this patch, while correct, will make receive
inconsistent with transmit. Presumably we should update the transmit
side as well.
