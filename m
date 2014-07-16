From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFCv3 08/14] arm64: introduce aarch64_insn_gen_movewide()
Date: Wed, 16 Jul 2014 17:17:15 +0100
Message-ID: <20140716161715.GU29414@arm.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
 <1405405512-4423-9-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405405512-4423-9-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 15, 2014 at 07:25:06AM +0100, Zi Shen Lim wrote:
> Introduce function to generate move wide (immediate) instructions.

[...]

> +u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
> +			      int imm, int shift,
> +			      enum aarch64_insn_variant variant,
> +			      enum aarch64_insn_movewide_type type)
> +{
> +	u32 insn;
> +
> +	switch (type) {
> +	case AARCH64_INSN_MOVEWIDE_ZERO:
> +		insn = aarch64_insn_get_movz_value();
> +		break;
> +	case AARCH64_INSN_MOVEWIDE_KEEP:
> +		insn = aarch64_insn_get_movk_value();
> +		break;
> +	case AARCH64_INSN_MOVEWIDE_INVERSE:
> +		insn = aarch64_insn_get_movn_value();
> +		break;
> +	default:
> +		BUG_ON(1);
> +	}
> +
> +	BUG_ON(imm < 0 || imm > 65535);

Do this check with masking instead?

> +
> +	switch (variant) {
> +	case AARCH64_INSN_VARIANT_32BIT:
> +		BUG_ON(shift != 0 && shift != 16);
> +		break;
> +	case AARCH64_INSN_VARIANT_64BIT:
> +		insn |= BIT(31);
> +		BUG_ON(shift != 0 && shift != 16 && shift != 32 &&
> +		       shift != 48);

Would be neater as a nested switch, perhaps? If you reorder the
outer-switch, you could probably fall-through too and combine the shift
checks.

Will
