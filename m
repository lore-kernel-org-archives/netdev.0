From: Michael Neuling <mikey@neuling.org>
Subject: Re: [2.6.19 PATCH 5/7] ehea: main header files
Date: Fri, 18 Aug 2006 13:03:41 -0500
Message-ID: <20060818180345.9660E67B64@ozlabs.org>
References: <200608181334.57701.ossthema@de.ibm.com>
Reply-To: Michael Neuling <mikey@neuling.org>
Cc: netdev <netdev@vger.kernel.org>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47026 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751455AbWHRSDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 14:03:47 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-reply-to: <200608181334.57701.ossthema@de.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static inline void ehea_update_sqa(struct ehea_qp *qp, u16 nr_wqes)
> +{
> +	struct h_epa epa = qp->epas.kernel;
> +	epa_store_acc(epa, QPTEMM_OFFSET(qpx_sqa),
> +		      EHEA_BMASK_SET(QPX_SQA_VALUE, nr_wqes));
> +}
> +
> +static inline void ehea_update_rq3a(struct ehea_qp *qp, u16 nr_wqes)
> +{
> +	struct h_epa epa = qp->epas.kernel;
> +	epa_store_acc(epa, QPTEMM_OFFSET(qpx_rq3a),
> +		      EHEA_BMASK_SET(QPX_RQ1A_VALUE, nr_wqes));
> +}
> +
> +static inline void ehea_update_rq2a(struct ehea_qp *qp, u16 nr_wqes)
> +{
> +	struct h_epa epa = qp->epas.kernel;
> +	epa_store_acc(epa, QPTEMM_OFFSET(qpx_rq2a),
> +		      EHEA_BMASK_SET(QPX_RQ1A_VALUE, nr_wqes));
> +}
> +
> +static inline void ehea_update_rq1a(struct ehea_qp *qp, u16 nr_wqes)
> +{
> +	struct h_epa epa = qp->epas.kernel;
> +	epa_store_acc(epa, QPTEMM_OFFSET(qpx_rq1a),
> +		      EHEA_BMASK_SET(QPX_RQ1A_VALUE, nr_wqes));
> +}
> +
> +static inline void ehea_update_feca(struct ehea_cq *cq, u32 nr_cqes)
> +{
> +	struct h_epa epa = cq->epas.kernel;
> +	epa_store_acc(epa, CQTEMM_OFFSET(cqx_feca),
> +		      EHEA_BMASK_SET(CQX_FECADDER, nr_cqes));
> +}
> +
> +static inline void ehea_reset_cq_n1(struct ehea_cq *cq)
> +{
> +	struct h_epa epa = cq->epas.kernel;
> +	epa_store_cq(epa, cqx_n1,
> +		     EHEA_BMASK_SET(CQX_N1_GENERATE_COMP_EVENT, 1));
> +}
> +
> +static inline void ehea_reset_cq_ep(struct ehea_cq *my_cq)
> +{
> +	struct h_epa epa = my_cq->epas.kernel;
> +	epa_store_acc(epa, CQTEMM_OFFSET(cqx_ep),
> +		      EHEA_BMASK_SET(CQX_EP_EVENT_PENDING, 0));
> +}

These are almost identical... I'm sure most (if not all) could be merged
into a single function or #define.

Mikey
