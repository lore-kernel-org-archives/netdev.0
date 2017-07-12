From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] rt2x00: make const array glrt_table static
Date: Wed, 12 Jul 2017 08:04:40 +0100
Message-ID: <ff540218-a260-98ac-b1d1-d4b9f3317a9f@canonical.com>
References: <20170711114733.15387-1-colin.king@canonical.com>
 <20170712064911.GA2769@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33661 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756700AbdGLHEn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 03:04:43 -0400
In-Reply-To: <20170712064911.GA2769@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/17 07:49, Stanislaw Gruszka wrote:
> On Tue, Jul 11, 2017 at 12:47:33PM +0100, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> Don't populate array glrt_table on the stack but make it static.
>> Makes the object code a smaller by over 670 bytes:
>>
>> Before:
>>    text	   data	    bss	    dec	    hex	filename
>>  131772	   4733	      0	 136505	  21539	rt2800lib.o
>>
>> After:
>>    text	   data	    bss	    dec	    hex	filename
>>  131043	   4789	      0	 135832	  21298	rt2800lib.o
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
> 
> I wonder why compiler do not optimize by itself since array is
> const, but patch is ok.

Afraid marking it as const does not guarantee that at all. The const
qualifier just announces that the value will not be changed [1]. So one
requires static const to ensure it's not populated on the stack and also
marked as non-modifiable.

[1] Section A4.4, The C programming Language, page 196

Colin

> 
> Stanislaw 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
