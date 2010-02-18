From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 10:25:13 +0100
Message-ID: <4B7D0779.6010609@lastsummer.de>
References: <4B7AAE69.8020701@simula.no> <20100217.163255.133898079.davem@davemloft.net> <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi> <4B7CFDE4.4010003@simula.no> <4B7D01CE.1030101@lastsummer.de> <alpine.DEB.2.00.1002181102260.9961@melkinpaasi.cs.helsinki.fi> <4B7D05ED.4060900@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Franco Fichtner <franco@lastsummer.de>,
	Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	hannemann@nets.rwth-aachen.de, LKML <linux-kernel@vger.kernel.org>,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7D05ED.4060900@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Petlund wrote:
> On 02/18/2010 10:09 AM, Ilpo J=E4rvinen wrote:
>  =20
>> On Thu, 18 Feb 2010, Franco Fichtner wrote:
>>
>>    =20
>>> Andreas Petlund wrote:
>>>      =20
>>>> On 02/18/2010 09:41 AM, Ilpo J=E4rvinen wrote:
>>>>  =20
>>>>        =20
>>>>> On Wed, 17 Feb 2010, David Miller wrote:
>>>>>
>>>>>    =20
>>>>>          =20
>>>>>> From: Andreas Petlund <apetlund@simula.no>
>>>>>> Date: Tue, 16 Feb 2010 15:40:41 +0100
>>>>>>
>>>>>>      =20
>>>>>>            =20
>>>>>>> @@ -341,6 +342,8 @@ struct tcp_sock {
>>>>>>>  	u16	advmss;		/* Advertised MSS
>>>>>>> */
>>>>>>>  	u8	frto_counter;	/* Number of new acks after RTO */
>>>>>>>  	u8	nonagle;	/* Disable Nagle algorithm?
>>>>>>> */
>>>>>>> +	u8      thin_lto    : 1,/* Use linear timeouts for thin
>>>>>>> streams */
>>>>>>> +		thin_undef  : 7;
>>>>>>>         =20
>>>>>>>              =20
>>>>>> There is now a gap of 3 unused bytes here in this critical
>>>>>> core TCP socket data structure.
>>>>>>
>>>>>> Please either find a way to avoid this hole, or document
>>>>>> it with a comment.
>>>>>>      =20
>>>>>>            =20
>>>>> There would be multiple bits free for use in both frto_counter an=
d nonagle
>>>>> byte.
>>>>>
>>>>>    =20
>>>>>          =20
>>>> I was playing aroud with this setup:
>>>>
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> u8	nonagle     : 4,/* Disable Nagle algorithm?             */
>>>> 	thin_lto    : 1,/* Use linear timeouts for thin streams */
>>>> 	thin_dupack : 1,/* Fast retransmit on first dupack      */
>>>> 	thin_undef  : 2;
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>
>>>> Do you think that would do the trick?
>>>>  =20
>>>>        =20
>>> According to Ilpo, it would be ok to reduce both ftro_counter and
>>> nonagle, so why not join all these into u16 and leave the remaining
>>> free bits documented for other people. Like this:
>>>
>>>    u16 frto_counter:x; /* Number of new acks after RTO */
>>>    u16 nonagle:y; /* Disable Nagle algorithm? */
>>>    u16 thin_lto:1; /* Use linear timeouts for thin streams */
>>>    u16 unused:15-x-y;
>>>
>>> Not sure about the y and x. Ilpo, can you comment on those values?
>>>      =20
>> I don't remember top of the hat how much of nonagle used, but for=20
>> frto_counter max value was 3 iirc.=20
>>    =20
>
> I think nonagle uses 4 bits:
> =3D=3D=3D=3D=3D=3D
> #define TCP_NAGLE_OFF           1       /* Nagle's algo is disabled *=
/
> #define TCP_NAGLE_CORK          2       /* Socket is corked         *=
/
> #define TCP_NAGLE_PUSH          4       /* Cork is overridden for alr=
eady queued data */
> =3D=3D=3D=3D=3D=3D
>
>  =20
That would be 3 bits. :)

>> However, I'm unsure if compiler is=20
>> nowadays wise enough to handle bitfields in some not all so stupid w=
ay.
>>    =20
>
> Would you then recommend to use a byte for each value, thus avoiding =
the bitfields?
>  =20
No, he meant he's not sure if the compiler can merge the bitfields in a=
=20
clever
way if written like this.

I use this style all the time at work and according to pahole it's okay=
=2E=20
But then,
I'm not sure if pahole can be trusted or if there is some compiler twis=
t on
non-intel architectures.


=46ranco
