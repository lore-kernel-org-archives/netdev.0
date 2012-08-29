From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] iproute2: tc.8: update UNITS section.
Date: Wed, 29 Aug 2012 08:49:46 +0800
Message-ID: <503D672A.5010006@cn.fujitsu.com>
References: <1346132337-21325-1-git-send-email-lw@cn.fujitsu.com> <1346172858.15747.25.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:43154 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab2H2AvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 20:51:13 -0400
In-Reply-To: <1346172858.15747.25.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2012 12:54 AM, Ben Hutchings wrote:
> On Tue, 2012-08-28 at 13:38 +0800, Li Wei wrote:
>> - rename section UNITS to PARAMETERS.
>> - break section PARAMETERS down to four subsections to cover the
>>   common used parameter types(RATES, TIMES, SIZES, VALUES).
>> - add some explaination for IEC units in RATES.
>> - point out the max value we can set for RATES, TIMES and SIZES.
>>
>> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
>> ---
>>  man/man8/tc.8 |  111 +++++++++++++++++++++++++++++++++++++++++++--------------
>>  1 file changed, 85 insertions(+), 26 deletions(-)
>>
>> diff --git a/man/man8/tc.8 b/man/man8/tc.8
>> index 98fbfcd..44d644a 100644
>> --- a/man/man8/tc.8
>> +++ b/man/man8/tc.8
>> @@ -257,19 +257,20 @@ qdiscs applies.
>>  FILTERS
>>  Filters have a three part ID, which is only needed when using a hashed
>>  filter hierarchy.
>> -.SH UNITS
>> -All parameters accept a floating point number, possibly followed by a unit.
>> -.P
>> -Bandwidths or rates can be specified in:
>> -.TP
>> -bps
>> -Bytes per second
>> +
>> +.SH PARAMETERS
>> +These following parameters are widely used in TC, for other parameters,
> 
> 'These' should be 'The'.
> 'for other parameters' should begin a new sentence.
> 
>> +see the man page for individual qdiscs.
> 
> 'page' should be 'pages'.
> 
>> +
>>  .TP
>> -kbps
>> -Kilobytes per second
>> +RATES
>> +Bandwidths or rates.
>> +These parameters accept a floating point number, possibly followed by
>> +a unit(both SI and IEC units supported).
> 
> Missing space before the open-parenthesis.
> 
>> +.RS
>>  .TP
>> -mbps
>> -Megabytes per second
>> +bit or a bare number
>> +Bits per second
>>  .TP
>>  kbit
>>  Kilobits per second
>> @@ -277,27 +278,41 @@ Kilobits per second
>>  mbit
>>  Megabits per second
>>  .TP
>> -bit or a bare number
>> -Bits per second
>> -.P
>> -Amounts of data can be specified in:
>> +gbit
>> +Gegabits per second
> 
> 'Gigabits'
> 
>>  .TP
>> -kb or k
>> -Kilobytes
>> +tbit
>> +Terabits per second
>>  .TP
>> -mb or m
>> -Megabytes
>> +bps
>> +Bytes per second
>>  .TP
>> -mbit
>> -Megabits
>> +kbps
>> +Kilobytes per second
>>  .TP
>> -kbit
>> -Kilobits
>> +mbps
>> +Megabytes per second
>>  .TP
>> -b or a bare number
>> -Bytes.
>> +gbps
>> +Gigabytes per second
>> +.TP
>> +tbps
>> +Terabytes per second
>> +
>> +.P
>> +To specified in IEC units, just replace the SI prefix(k-, m-, g-, t-) with
>> +IEC prefix(ki-, mi-, gi- and ti-) respectively.
> 
> 'specified' should be 'specify'.
> The word 'just' is not needed.
> 
> Missing spaces before the open-parentheses.
> 
>> +
>>  .P
>> -Lengths of time can be specified in:
>> +TC store rates as a __u32 integer in bps internally,
>> +so we can specify a max rate of UINT32_MAX bps.
>> +.RE
>> +
>> +.TP
>> +TIMES
>> +Length of time. Can be specified as a float pointing number 
> 
> 'float pointing' should be 'floating point' :-)
> 
>> +followed by an optional unit:
>> +.RS
>>  .TP
>>  s, sec or secs
>>  Whole seconds
>> @@ -308,6 +323,50 @@ Milliseconds
>>  us, usec, usecs or a bare number
>>  Microseconds.
>>  
>> +.P
>> +TC defined it's own time unit(equals to microsecond) and store time values
> 
> 'it's' means 'it is'; here it should be 'its'.
> 'equals' should be 'equal'.
> 'store' should be 'stores'.
> 
> Missing space before the open parenthesis, again.
> 
>> +as __u32 integer, thus we can specify a max time value of UINT32_MAX usecs.
> 
> I don't think user documentation should use names like '__u32' and
> 'UINT32_MAX'.  Instead it should say '32-bit unsigned integer' and '4294
> seconds'.
> 
>> +.RE
>> +
>> +.TP
>> +SIZES
>> +Amounts of data. Can be specified as a float pointing number 
> 
> 'float pointing' should be 'floating point' again
> 
>> +followed by an optional unit:
>> +.RS
>> +.TP
>> +b or a bare number
>> +Bytes.
>> +.TP
>> +kbit
>> +Kilobites
> 
> 'kilobits'
> 
>> +.TP
>> +kb or k
>> +Kilobytes
>> +.TP
>> +mbit
>> +Megabits
>> +.TP
>> +mb or m
>> +Megabytes
>> +.TP
>> +gbit
>> +Gigabites
> 
> 'gigabits'
> 
>> +.TP
>> +gb or g
>> +Gigabytes
>> +
>> +.P
>> +TC store sizes internally as __u32 integer in byte, so we can specify
>> +a max size of UINT32_MAX bytes.
> 
> 'store' should be 'stores'.
> Same issue with the type and maximum names.
> 
>> +.RE
>> +
>> +.TP
>> +VALUES
>> +Other values without a unit.
>> +These parameters read as decimal by default, but you can
> 
> 'read' should be 'are read' or 'are interpreted'
> 
> Ben.

Sorry for my poor english, I'll modify and resend this patch.

Thanks Ben :)

> 
>> +indicate TC to read them as octal and hexadecimal by adding a '0'
>> +or '0x' prefix respectively.
>> +
>>  .SH TC COMMANDS
>>  The following commands are available for qdiscs, classes and filter:
>>  .TP
> 
