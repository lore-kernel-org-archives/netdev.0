From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [PATCH net-next] net: add skb allocation flags to __pskb_copy
Date: Sun, 8 Jun 2014 19:49:30 +0300
Message-ID: <CAE1zotLJ41cOtUVES-CN=kmJzjVTpR_4Mm966aqvEacn21QamQ@mail.gmail.com>
References: <b75b291eb5364f13904268302d789357@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	<20140608155941.GL5219@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:60562 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbaFHQtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 12:49:32 -0400
Received: by mail-wi0-f169.google.com with SMTP id hi2so921343wib.4
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 09:49:30 -0700 (PDT)
In-Reply-To: <20140608155941.GL5219@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GOn Sun, Jun 8, 2014 at 6:59 PM, Christoph Paasch
<christoph.paasch@uclouvain.be> wrote:
> Hello Octavian,
>
> On 07/06/14 - 22:19:29, Octavian Purdila wrote:
>> There are several instances where a __pskb_copy is immediately
>> followed by an skb_clone. Add a new parameter to __pskb_copy to allow
>> the skb to be allocated from the fclone cache and thus speed up
>> subsequent skb_clone calls.
>>
>> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
>> ---
>>  include/linux/skbuff.h   | 6 +++---
>>  net/bluetooth/hci_sock.c | 5 +++--
>>  net/core/skbuff.c        | 7 +++++--
>>  net/ipv4/tcp_output.c    | 2 +-
>>  net/nfc/llcp_core.c      | 2 +-
>>  net/nfc/rawsock.c        | 2 +-
>>  6 files changed, 14 insertions(+), 10 deletions(-)
>
> I found two more cases where the stack could benefit from using an FCLONE:
>
> * batadv_nc_skb_store_before_coding() does a pskb_copy and later in
>   batadv_nc_skb_store_for_decoding() the skb_clone is done.
>
> * tipc_bcbearer_send() also does a pskb_copy, and the send_msg-callback (in
>   tipc_bearer_send()) does a clone too later on in tipc_l2_send_msg().
>

Missed those, I will send a new patch which adds a new parameter to
psbk_copy as well then.
