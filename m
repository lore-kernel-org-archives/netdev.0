From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 05/18] mlxsw: spectrum_buffers: Push out indexes
 and direction out of SB structs
Date: Fri, 15 Apr 2016 10:52:59 +0200
Message-ID: <20160415085259.GB1911@nanopsycho.orion>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
 <1460650770-19382-6-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D5F4A2E99@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"rami.rosen@intel.com" <rami.rosen@intel.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38421 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbcDOIxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 04:53:03 -0400
Received: by mail-wm0-f43.google.com with SMTP id u206so22214211wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 01:53:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4A2E99@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 15, 2016 at 10:33:27AM CEST, David.Laight@ACULAB.COM wrote:
>From: Jiri Pirko
>> Sent: 14 April 2016 17:19
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Structs are in arrays so use array index as pool/tc/prio index. With
>> that, there is need to maintain separate arrays for ingress and egress.
>...
>> +static const u16 mlxsw_sp_pbs[] = {
>> +	2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN),
>> +	0,
>> +	0,
>> +	0,
>> +	0,
>> +	0,
>> +	0,
>> +	0,
>> +	0, /* Unused */
>> +	2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU),
>>  };
>
>Use designated initialisers.

Okay

>
>> 
>>  #define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
>> @@ -106,10 +96,9 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
>>  	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port,
>>  			    0xffff, 0xffff / 2);
>>  	for (i = 0; i < MLXSW_SP_PBS_LEN; i++) {
>
>I'd rather see an explicit ARRAY_COUNT(mlxsw_sp_pbs) than some 'randon' constant.

See "#define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)"


>
>> -		const struct mlxsw_sp_pb *pb;
>> -
>> -		pb = &mlxsw_sp_pbs[i];
>> -		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pb->index, pb->size);
>> +		if (i == 8)
>> +			continue;
>
>I'm guessing that is the same '8' as the commented 'unused' slot when mlxsw_sp_pbs[]
>is initialised.
>Would be better if a named constant.
>If this in initialisation code an illegal value (maybe 0xffff) to mark the
>unused slot.

Okay. Will send follow-up to make this a bit nicer. Thanks.


>
>> +		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, i, mlxsw_sp_pbs[i]);
>
>	David
>
