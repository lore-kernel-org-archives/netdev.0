From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next 3/3] xfrm: Add file to document IPsec corner
 case
Date: Mon, 16 Dec 2013 17:58:50 +0800
Message-ID: <52AECEDA.80403@windriver.com>
References: <1387099194-18540-1-git-send-email-fan.du@windriver.com> <1387099194-18540-4-git-send-email-fan.du@windriver.com> <20131216094622.GF31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60345 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab3LPJ7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 04:59:04 -0500
In-Reply-To: <20131216094622.GF31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 17:46, Steffen Klassert wrote:
> On Sun, Dec 15, 2013 at 05:19:54PM +0800, Fan Du wrote:
>> Create Documentation/networking/ipsec.txt to document IPsec
>> corner issues and other info, which will be useful when user
>> deploying IPsec.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   Documentation/networking/ipsec.txt |   40 ++++++++++++++++++++++++=
++++++++++++
>>   1 file changed, 40 insertions(+)
>>   create mode 100644 Documentation/networking/ipsec.txt
>>
>> diff --git a/Documentation/networking/ipsec.txt b/Documentation/netw=
orking/ipsec.txt
>> new file mode 100644
>> index 0000000..3b02806
>> --- /dev/null
>> +++ b/Documentation/networking/ipsec.txt
>> @@ -0,0 +1,40 @@
>> +
>> +Here documents known IPsec corner cases which need to be keep in mi=
nd when
>> +deploy various IPsec configuration in real world production environ=
ment.
>> +
>> +1. IPcomp: Small IP packet won't get compressed at sender, and fail=
ed on
>> +	   policy check on receiver.
>> +
>> +Quote from RFC3173:
>> +2.2. Non-Expansion Policy
>> +
>> +   If the total size of a compressed payload and the IPComp header,=
 as
>> +   defined in section 3, is not smaller than the size of the origin=
al
>> +   payload, the IP datagram MUST be sent in the original non-compre=
ssed
>> +   form.  To clarify: If an IP datagram is sent non-compressed, no
>> +
>> +   IPComp header is added to the datagram.  This policy ensures sav=
ing
>> +   the decompression processing cycles and avoiding incurring IP
>> +   datagram fragmentation when the expanded datagram is larger than=
 the
>> +   MTU.
>> +
>> +   Small IP datagrams are likely to expand as a result of compressi=
on.
>> +   Therefore, a numeric threshold should be applied before compress=
ion,
>> +   where IP datagrams of size smaller than the threshold are sent i=
n the
>> +   original form without attempting compression.  The numeric thres=
hold
>> +   is implementation dependent.
>> +
>> +Current IPComp implementation is indeed by the book, while as in pr=
actice
>> +when sending non-compressed packet to the peer(whether or not packe=
t len
>> +is smaller than the threshold or the compressed len is large than o=
riginal
>> +packet len), the packet is dropped when checking the policy as this=
 packet
>> +matches the selector but not coming from any XFRM layer, i.e., with=
 no
>> +security path. Such naked packet will not eventually make it to upp=
er layer.
>> +The result is much more wired to the user when ping peer with diffe=
rent
>> +payload length.
>> +
>> +One workaround is try to set "level use" for each policy if user ob=
served
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ here

>> +above scenario. The consequence of doing so is small packet(uncompr=
essed)
>> +will skip policy checking on receiver side.
>> +
>> +
>
> Please remove the empty lines at the end of the file.
>
> Also, it might be good to mention what the user exactly
> has configure do to get a workaround.
     It's in above here..

Will fix while space error, sorry for such mistakes.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
