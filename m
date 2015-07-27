From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH v4 net-next 1/4] tcp: replace cnt & rtt with struct
 in pkts_acked()
Date: Mon, 27 Jul 2015 19:30:39 +0000
Message-ID: <D1DBD200.6038%brakmo@fb.com>
References: <1437792426-1724090-1-git-send-email-brakmo@fb.com>
 <1437792426-1724090-2-git-send-email-brakmo@fb.com>
 <20150727114601.42fc6b63@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
	"Neal Cardwell" <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:62511 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754182AbbG0Tap convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 15:30:45 -0400
In-Reply-To: <20150727114601.42fc6b63@urahara>
Content-Language: en-US
Content-ID: <89ECF114BE9F3A4C8D84E03F1AB8AE03@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/27/15, 11:46 AM, "Stephen Hemminger" <stephen@networkplumber.org>
wrote:

>On Fri, 24 Jul 2015 19:47:03 -0700
>Lawrence Brakmo <brakmo@fb.com> wrote:
>
>> Replace 2 arguments (cnt and rtt) in the congestion control modules'
>> pkts_acked() function with a struct. This will allow adding more
>> information without having to modify existing congestion control
>> modules (tcp_nv in particular needs bytes in flight when packet
>> was sent).
>>=20
>> As proposed by Neal Cardwell in his comments to the tcp_nv patch.
>
>Adding a layer of indirection makes code changes easier, but makes
>the code slower. Arguments are passed in registers, and putting an
>additional level of indirection only matters if you can't change
>all the CC modules. Since this is the kernel and API compatability
>doesn't matter, just pass more arguments.

I prefer the cleanliness of passing a structure and don=B9t think the
overhead will be significant enough to worry about it.
Will the compiler pass struct values in registers if the struct is
passed by value?

I will be happy to do it either way (I did it like Stephen proposes
originally). What does everyone else think?

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
